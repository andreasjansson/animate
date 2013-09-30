// TODO: Logging! (instead of returning err everywhere)
// to delete, must enter password

package main

import (
	"fmt"
	"log"
	"net/http"
	"encoding/json"
	"flag"
	"errors"
	"time"
	"crypto/sha1"
	"io"
	"io/ioutil"
	"net/url"
	"encoding/base64"
	"html/template"
	"math/rand"
	"database/sql"
	"github.com/dlintw/goconf"
	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

var config *goconf.ConfigFile

type JSONResponse map[string]interface{}

func (r JSONResponse) String() (s string) {
        b, err := json.Marshal(r)
        if err != nil {
                s = ""
                return
        }
        s = string(b)
        return
}

func dbConnect() (*sql.DB, error) {
	db, err := sql.Open(
		"mysql",
		conf("db", "user") + ":" +
			conf("db", "pass") + "@tcp(" +
			conf("db", "host") + ":" +
			conf("db", "port") + ")/" +
			conf("db", "name"))
	return db, err
}

func dbExec(query string, args ...interface{}) (sql.Result, error) {
	db, err := dbConnect()
	defer db.Close()
	if err != nil {
		return nil, err
	}
	return db.Exec(query, args...)
}

var ErrProjectNotFound error = errors.New("Project not found")

type Project struct {
	Name string
	Password string
	AudioURL string
	Analysis string
	Data string
	EditKey string
}

func (p *Project) Create() error {
	// requires Name, Password, AudioURL, and Analysis
	_, err := dbExec(
		`INSERT INTO projects (name, password, audio_url, analysis)
		 VALUES (?, ?, ?, ?)`, p.Name, p.Password, p.AudioURL, p.Analysis)
	return err
}

func (p *Project) Load() error {
	// requires Name and (Password or EditKey)
	db, err := dbConnect()
	var audioURL, analysis, data []byte
	query := `SELECT audio_url, analysis, data
		  FROM projects
		  WHERE name=? `
	var keyParam string
	if p.Password != "" {
		query += "AND password=?"
		keyParam = p.Password
	} else if p.EditKey != "" {
		query += "AND edit_key=?"
		keyParam = p.EditKey
	}
	var row *sql.Row
	if keyParam != "" {
		row = db.QueryRow(query, p.Name, keyParam)
	} else {
		row = db.QueryRow(query, p.Name)
	}
	err = row.Scan(&audioURL, &analysis, &data)
	if err == sql.ErrNoRows {
		return ErrProjectNotFound
	} else if err != nil {
		return err
	}

	p.AudioURL = string(audioURL)
	p.Analysis = string(analysis)
	p.Data = string(data)

	return err
}

func (p *Project) Update() error {
	// requires Name and EditKey
	_, err := dbExec(
		"UPDATE projects SET data=? WHERE name=? AND edit_key=?",
		p.Data, p.Name, p.EditKey)
	if err != nil {
		return err
	}
	return nil
}

func (p *Project) Delete() error {
	// requires Name and EditKey
	result, err := dbExec(
		"DELETE FROM projects WHERE name=? AND edit_key=?",
		p.Name, p.EditKey)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrProjectNotFound
	}
	return nil
}

func (p *Project) SetEditKey(key string) error {
	result, err := dbExec(
		"UPDATE projects SET edit_key=? WHERE name=? AND password=?",
		key, p.Name, p.Password)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrProjectNotFound
	}
	p.EditKey = key
	return nil
}

func uniqueName() (string, error) {
	db, err := dbConnect()
	if err != nil {
		return "", err
	}

	length := 8
	attempts := 10
	exists := 0
	for i := 0; i < attempts; i ++ {
		name := randomString(length)
		row := db.QueryRow("SELECT 1 FROM projects WHERE name=?", name)
		err := row.Scan(exists)
		if err == sql.ErrNoRows {
			return name, nil
		} else if err != nil {
			return "", err
		}
	}
	return "", errors.New("Failed to find a name")
}

var letters = "abcdefghijklmnopqrstuvwxyz"
func randomString(length int) string {
	s := ""
	for i := 0; i < length; i ++ {
		s += string(letters[rand.Intn(len(letters))])
	}
	return s
}

type RawAnalysis struct {
	Sections []map[string]float64
	Bars []map[string]float64
	Beats []map[string]float64
}

type Analysis struct {
	Duration float64
	Sections []float64
	Bars []float64
	Beats []float64
}

func (a *Analysis) String() string {
	ret, _ := json.Marshal(a)
	return string(ret)
}

func apiPost(call string, vars url.Values) ([]byte, error) {
	vars.Add("api_key", conf("default", "echo_nest_api_key"))
	url := "http://developer.echonest.com/api/v4/" + call
	log.Println(url, vars)
	resp, err := http.PostForm(url, vars)
	if err != nil {
		return nil, err
	}
	str, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	return str, err
}

func httpGet(url string) ([]byte, error) {
	log.Println(url)
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	str, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	return str, err
}

func apiGet(call string, vars url.Values) ([]byte, error) {
	if vars == nil {
		vars = url.Values{}
	}
	vars.Add("api_key", conf("default", "echo_nest_api_key"))
	url := "http://developer.echonest.com/api/v4/" + call
	url += "?" + vars.Encode()
	return httpGet(url)
}

func analyse(audioURL string) (*Analysis, error) {
	resp, err := apiPost("track/upload", url.Values{"url": {audioURL}})
	if err != nil {
		return nil, err
	}

	fmt.Println(string(resp))

	var raw map[string]map[string]map[string]interface{}
	json.Unmarshal(resp, &raw)
	if len(raw["response"]["track"]) == 0 {
		log.Printf("Failed to analyse %s, response: %v", audioURL, raw["response"])
		return nil, errors.New("Failed to analyse audio file")
	}
	fmt.Println(raw["response"]["track"])
	md5 := raw["response"]["track"]["md5"].(string)

	attempts := 10
	for i := 0; i < attempts; i ++ {
		resp, err = apiGet("track/profile",
			url.Values{"md5": {md5}, "bucket": {"audio_summary"}})
		if err != nil {
			return nil, err
		}
		
		json.Unmarshal(resp, &raw)
		status := raw["response"]["track"]["status"]
		if status == "complete" {
			audioSummary := raw["response"]["track"]["audio_summary"].(map[string]interface{})
			analysisURL := audioSummary["analysis_url"].(string)
			resp, err = httpGet(analysisURL)
			if err != nil {
				return nil, err
			}
			
			analysis, err := parseAnalysis(resp)
			analysis.Duration = audioSummary["duration"].(float64)
			return analysis, err
		}
		if status == "error" {
			fmt.Println(raw["response"])
			log.Printf("Analysis failed for ", md5)
			break
		}

		log.Printf("Analysis not complete for MD5 %s", md5)
		time.Sleep(3 * time.Second)
	}

	return nil, errors.New("analysis failed")
}

func parseAnalysis(str []byte) (*Analysis, error) {
	ioutil.WriteFile("analysis.txt", str, 0777)
	var rawAnalysis RawAnalysis
	json.Unmarshal(str, &rawAnalysis)

	getStarts := func(maps []map[string]float64) (starts []float64) {
		starts = make([]float64, len(maps))
		for i, m := range maps {
			starts[i] = m["start"]
		}
		return
	}
	analysis := &Analysis{
		Sections: getStarts(rawAnalysis.Sections),
		Bars: getStarts(rawAnalysis.Bars),
		Beats: getStarts(rawAnalysis.Beats),
	}
	
	return analysis, nil
}

func path(relative string) (absolute string) {
	absolute = fmt.Sprintf("%s/%s", conf("default", "root_dir"), relative)
	return
}

func renderTemplate(w http.ResponseWriter, filename string) {
	tpl, err := template.ParseFiles(path("html/base.html.tpl"), path(filename))
	if err != nil {
		panic(err)
	}

	err = tpl.ExecuteTemplate(w, "base", nil)
	if err != nil {
		panic(err)
	}
}

func IndexHandler(w http.ResponseWriter, r *http.Request) {
	renderTemplate(w, "html/index.html.tpl")
	return
}

func CreateHandler(w http.ResponseWriter, r *http.Request) {
	renderTemplate(w, "html/create.html.tpl")
	return
}

func CreateSubmitHandler(w http.ResponseWriter, r *http.Request) {

	audioURL := r.FormValue("audio-url")
	password := r.FormValue("password")
	if audioURL == "" || password == "" {
		http.Error(w, "missing attributes", http.StatusBadRequest)
		return
	}

	analysis, err := analyse(audioURL)
	if err != nil {
		// TODO: handle nicer
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	name, err := uniqueName()
	if err != nil {
		// TODO: handle nicer
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	password = encrypt(password)
	project := &Project{
		Name: name,
		Password: password,
		AudioURL: audioURL,
		Analysis: analysis.String(),
	}
	err = project.Create()

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, JSONResponse{"name": name})
	return
}

func EditFormHandler(w http.ResponseWriter, r *http.Request) {

	name := r.FormValue("name")

	tpl, err := template.ParseFiles(path("html/base.html.tpl"), path("html/editform.html.tpl"))
	if err != nil {
		panic(err)
	}

	data := map[string]string {
		"Name": name,
	}
	err = tpl.ExecuteTemplate(w, "base", data)
	if err != nil {
		panic(err)
	}
	return
}

func EditSubmitHandler(w http.ResponseWriter, r *http.Request) {

	name := r.FormValue("name")
	password := r.FormValue("password")
	if name == "" || password == "" {
		http.Error(w, "missing attributes", http.StatusBadRequest)
		return
	}
	
	password = encrypt(password)

	project := &Project{Name: name, Password: password}
	err := project.Load()
	if err != nil {
		if err == ErrProjectNotFound {
			http.NotFound(w, r)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}

	project.SetEditKey(encrypt(password + randomString(10)))

	http.SetCookie(w, &http.Cookie{
		Name: "key-" + project.Name,
		Value: project.EditKey,
		Expires: time.Now().AddDate(0, 0, 7),
	})

	http.Redirect(w, r, "/edit/" + project.Name, 302)
	return
}

func EditHandler(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	name := vars["name"]

	cookie, err := r.Cookie("key-" + name)
	if err != nil {
		http.Redirect(w, r, "/edit?name=" + name, 302)
		return
	}

	project := &Project{Name: name, EditKey: cookie.Value}
	err = project.Load()
	if err != nil {
		http.Redirect(w, r, "/edit?name=" + name, 302)
	}
	
	tpl, err := template.ParseFiles(path("html/base.html.tpl"), path("html/edit.html.tpl"))
	if err != nil {
		panic(err)
	}

	if project.Data == "" {
		project.Data = "{}"
	}

	data := map[string]template.JS{
		"Name": template.JS(project.Name),
		"Data": template.JS(project.Data),
		"AudioURL": template.JS(project.AudioURL),
		"Analysis": template.JS(project.Analysis),
	}

	err = tpl.ExecuteTemplate(w, "base", data)
	if err != nil {
		panic(err)
	}
	return
}

func SaveHandler(w http.ResponseWriter, r *http.Request) {

	name := r.FormValue("name")
	data := r.FormValue("data")
	if name == "" || data == "" {
		http.Error(w, "Missing attributes", http.StatusBadRequest)
		return
	}

	cookie, err := r.Cookie("key-" + name)
	if err != nil {
		http.Redirect(w, r, "Please re-authenticate" + name, 302)
		return
	}

	project := &Project{Name: name, EditKey: cookie.Value}
	err = project.Load()
	if err != nil {
		if err == ErrProjectNotFound {
			http.NotFound(w, r)
		} else {
			fmt.Print(err)
			http.Error(w, "Database error", http.StatusInternalServerError)
		}
		return
	}

	project.Data = data
	err = project.Update()
	if err != nil {
		fmt.Print(err)
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, JSONResponse{"status": "OK"})
}

func BounceHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	name := vars["name"]

	project := &Project{Name: name}
	err := project.Load()
	if err != nil {
		if err == ErrProjectNotFound {
			http.NotFound(w, r)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}

	if project.Data == "" {
		project.Data = "{}"
	}

	tpl, err := template.ParseFiles(path("html/bounce.html.tpl"))
	if err != nil {
		panic(err)
	}

	data := map[string]template.JS{
		"Name": template.JS(project.Name),
		"Data": template.JS(project.Data),
		"AudioURL": template.JS(project.AudioURL),
		"Analysis": template.JS(project.Analysis),
		"Prefix": "mvap",
	}

	err = tpl.ExecuteTemplate(w, "bounce", data)
	if err != nil {
		panic(err)
	}

	return
}

func encrypt(input string) string {
	hash := sha1.New()
	io.WriteString(hash, input)
	return base64.URLEncoding.EncodeToString(hash.Sum(nil))
}

func conf(section string, name string) string {
	value, err := config.GetString(section, name)
	if err != nil {
		panic(err)
	}
	return value
}

func route() {
	r := mux.NewRouter()
	post := r.Methods("POST").Subrouter()
	get := r.Methods("GET").Subrouter()
	
	get.HandleFunc("/", IndexHandler)

	get.HandleFunc("/create", CreateHandler)
	post.HandleFunc("/create", CreateSubmitHandler)

	get.HandleFunc("/edit", EditFormHandler)
	post.HandleFunc("/edit", EditSubmitHandler)
	get.HandleFunc("/edit/{name}", EditHandler)

	post.HandleFunc("/save", SaveHandler)

	http.Handle("/js/app/", CoffeeFileServer(path("")))
	http.Handle("/js/lib/", http.FileServer(http.Dir(path(""))))
	http.Handle("/css/", http.FileServer(http.Dir(path(""))))
	http.Handle("/static/", http.FileServer(http.Dir(path(""))))

	get.HandleFunc("/{name}", BounceHandler)

	http.Handle("/", r)

	fmt.Println("Listening on :8888")
	log.Fatal(http.ListenAndServe(":8888", nil))
}

func main() {
	var err error
	configFilename := flag.String("conf", "config.ini", "path to configuration file")
	flag.Parse()
	config, err = goconf.ReadConfigFile(*configFilename)
	if err != nil {
		panic(fmt.Sprintf("Failed to read config file: %v", err))
	}

	rand.Seed(time.Now().UnixNano()) 

	route()
}

// TODO: Logging!

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
)

var config *goconf.ConfigFile
var rootDir string

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
	Created int64
}

func (p *Project) Create() error {
	// requires Name, Password, AudioURL, and Analysis
	_, err := dbExec(
		`INSERT INTO projects (name, password, audio_url, analysis)
		 VALUES (?, ?, ?, ?)`, p.Name, p.Password, p.AudioURL, p.Analysis)
	return err
}

func (p *Project) Load() error {
	// requires Name and Password
	db, err := dbConnect()
	row := db.QueryRow(
		`SELECT audio_url, analysis, data, created
		 FROM projects
		 WHERE name=? AND password=?`, p.Name, p.Password)
	err = row.Scan(&p.AudioURL, &p.Analysis, &p.Data, &p.Created)
	if err == sql.ErrNoRows {
		return ErrProjectNotFound
	} else if err != nil {
		return err
	}

	return err
}

func (p *Project) Update() error {
	// requires Name and EditKey
	result, err := dbExec(
		"UPDATE projects SET data=? WHERE name=? AND key=?",
		p.Data, p.Name, p.EditKey)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrProjectNotFound
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
	resp, err := http.PostForm(url, vars)
	if err != nil {
		return nil, err
	}
	str, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	return str, err
}

func httpGet(url string) ([]byte, error) {
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

	var raw map[string]map[string]map[string]interface{}
	json.Unmarshal(resp, &raw)
	if len(raw["response"]["track"]) == 0 {
		log.Printf("Failed to analyse %s, response: %v", audioURL, raw["response"])
		return nil, errors.New("analysis failed")
	}
	md5 := raw["response"]["track"]["audio_md5"].(string)

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
			log.Println(analysisURL)
			resp, err = httpGet(analysisURL)
			if err != nil {
				return nil, err
			}
			
			analysis, err := parseAnalysis(resp)
			return analysis, err
		}
		if status == "error" {
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
	absolute = fmt.Sprintf("%s/%s", rootDir, relative)
	return
}

func index(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		http.Error(w, "method not allowed, must be GET", http.StatusMethodNotAllowed)
		return
	}
	w.Header().Set("Content-Type", "text/html")
	fmt.Println(path("html/index.html"))
	http.ServeFile(w, r, path("html/index.html"))
}

func create(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "method not allowed, must be POST", http.StatusMethodNotAllowed)
		return
	}
	
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

func edit(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "method not allowed, must be POST", http.StatusMethodNotAllowed)
		return
	}

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

	tmpl, err := template.ParseFiles(path("html/edit.html"))
	data := map[string]string{
		"name": project.Name,
		"key": project.EditKey,
		"data": project.Data,
		"audio-url": project.AudioURL,
		"analysis": project.Analysis,
	}
	tmpl.Execute(w, data)
	return
}

func save(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "method not allowed, must be POST", http.StatusMethodNotAllowed)
		return
	}

	name := r.FormValue("name")
	key := r.FormValue("key")
	data := r.FormValue("data")
	if name == "" || key == "" || data == "" {
		http.Error(w, "missing attributes", http.StatusBadRequest)
		return
	}

	// TODO check they're present

	project := &Project{Name: name, Data: data, EditKey: key}
	err := project.Update()
	if err != nil {
		if err == ErrProjectNotFound {
			http.NotFound(w, r)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, JSONResponse{"status": "OK"})
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

func main() {
	var err error
	configFilename := flag.String("conf", "config.ini", "path to configuration file")
	flag.Parse()
	config, err = goconf.ReadConfigFile(*configFilename)
	if err != nil {
		panic(fmt.Sprintf("Failed to read config file: %v", err))
	}
	rootDir = conf("default", "root_dir")

	rand.Seed(time.Now().UnixNano()) 

	fmt.Println("Listening on :8080")
	http.HandleFunc("/", index)
	http.HandleFunc("/create", create)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

package main

import (
	"fmt"
	"log"
	"net/http"
	"encoding/json"
	"github.com/dlintw/goconf"
	"flag"
)

var config *goconf.ConfigFile
var rootDir string

type Response map[string]interface{}

func (r Response) String() (s string) {
        b, err := json.Marshal(r)
        if err != nil {
                s = ""
                return
        }
        s = string(b)
        return
}

func path(relative string) (absolute string) {
	absolute = fmt.Sprintf("%s/%s", rootDir, relative)
	return
}

func index(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	fmt.Println(path("html/index.html"))
	http.ServeFile(w, r, path("html/index.html"))
}

func analyse(w http.ResponseWriter, r *http.Request) {
	audioUrl := r.FormValue("audio_url")
	fmt.Fprint(w, Response{"audio-url": audioUrl})
}

func main() {
	var err error
	configFilename := flag.String("conf", "config.ini", "path to configuration file")
	flag.Parse()
	config, err = goconf.ReadConfigFile(*configFilename)
	if err != nil {
		panic(fmt.Sprintf("Failed to read config file: %v", err))
	}
	rootDir, err = config.GetString("default", "root_dir")
	if err != nil {
		panic(err)
	}

	fmt.Println("Listening on :8080")
	http.HandleFunc("/", index)
	http.HandleFunc("/analyse", analyse)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

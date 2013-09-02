package main

import (
	"net/http"
	"errors"
	"strings"
	"os/exec"
	"os"
	"log"
)

var ErrNoSuchFile = errors.New("File not found")
var ErrFailedToCompile = errors.New("Failed to compile coffeescript")

type fileHandler struct {
	directory string
}

func CoffeeFileServer(directory string) http.Handler {
	return &fileHandler{directory}
}

func (f *fileHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	upath := r.URL.Path
	if strings.HasPrefix(upath, "/") {
		upath = upath[1:]
	}
	path := f.directory + upath
	err := compile(path)
	if err != nil {
		switch err {
		case ErrNoSuchFile:
			log.Printf("Couldn't find coffee file %s (%s)", upath, path)
			http.NotFound(w, r)
			return
		default:
			log.Printf("Failed to compile coffee to js: %v", err)
			http.Error(w, "", http.StatusInternalServerError)
			return
		}
	}
	http.ServeFile(w, r, path)
}

func compile(path string) error {
	parts := strings.Split(path, "/")
	js := parts[len(parts) - 1]

	if !strings.HasSuffix(js, ".js") {
		return nil
	}
	coffee := strings.Replace(js, ".js", ".coffee", 1)
	dir := strings.Join(parts[:len(parts) - 1], "/") + "/"
	jsInfo, jsErr := os.Stat(dir + js)
	coffeeInfo, coffeeErr := os.Stat(dir + coffee)
	if coffeeErr != nil && jsErr != nil {
		return ErrNoSuchFile
	}
	if coffeeErr != nil && jsErr == nil {
		return nil
	}

	if jsErr != nil || coffeeInfo.ModTime().After(jsInfo.ModTime()) {
		log.Printf("Recompiling %s", dir + coffee)
		cmd := exec.Command("coffee", "-c", "-m", "-o", dir, dir + coffee)
		err := cmd.Run()
		if err != nil {
			return err
		}
	}
	return nil
}

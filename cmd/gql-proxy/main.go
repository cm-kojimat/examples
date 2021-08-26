package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"

	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/gin-gonic/gin"
	"github.com/koding/websocketproxy"
)

func main() {
	r := gin.Default()

	appsync := r.Group("/appsync")

	uhttps, err := url.Parse(os.Getenv("APPSYNC_ENDPOINT_GRAPHQL"))
	if err != nil {
		log.Fatal(err)
	}

	appsync.Any("/graphql", gin.WrapH(&httputil.ReverseProxy{
		Director: func(req *http.Request) {
			req.URL.Scheme = uhttps.Scheme
			req.URL.Host = uhttps.Host
			req.URL.Path = uhttps.Path

			req.Host = uhttps.Host
			req.Header.Set("X-Api-Key", os.Getenv("APPSYNC_API_KEY"))
		},
	}))

	uwss, err := url.Parse(os.Getenv("APPSYNC_ENDPOINT_REALTIME"))
	if err != nil {
		log.Fatal(err)
	}
	hwss := websocketproxy.NewProxy(uwss)
	hwss.Director = func(req *http.Request, out http.Header) {
		log.Printf("%+v, %+v", req, out)

		req.URL.Scheme = uwss.Scheme
		req.URL.Host = uwss.Host
		req.URL.Path = uwss.Path

		req.Host = uwss.Host
		req.Header.Set("X-Api-Key", os.Getenv("APPSYNC_API_KEY"))
	}
	appsync.Any("/realtime", gin.WrapH(hwss))

	r.GET("/query", gin.WrapH(playground.Handler("GraphQL playground", "/appsync/graphql")))

	if err := r.Run(":8080"); err != nil {
		log.Fatal(err)
	}
}

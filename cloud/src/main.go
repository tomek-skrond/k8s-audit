package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type Server struct {
	listenPort string
	Database   *Storage
	tmpl       template.Template
}

func NewServer(db *Storage) *Server {
	temp := template.Must(template.ParseFiles("template/home.html"))
	return &Server{
		Database: db,
		tmpl:     *temp,
	}
}

// Handler
func (s *Server) Home(c echo.Context) error {
	fruits, err := s.Database.GetFruit()
	if err != nil {
		return err
	}
	fmt.Println(&fruits)

	return s.tmpl.Execute(c.Response().Writer, fruits)
}

func (s *Server) InsertFruitHandler(c echo.Context) error {

	name := c.FormValue("name")
	taste := c.FormValue("taste")
	rating := c.FormValue("rating")

	fmt.Println(name, taste, rating)

	newFruitReq := &Fruit{
		Name:   name,
		Taste:  taste,
		Rating: rating,
	}
	// if err := c.Bind(newFruitReq); err != nil {
	// 	return err
	// }
	fmt.Println(newFruitReq)
	if err := s.Database.InsertFruit(*newFruitReq); err != nil {
		fmt.Println("insert err")
		return err
	}

	return c.Redirect(302, "/")
}

func (s *Server) DeleteFruitHandler(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		fmt.Println("conversion error")
		return err
	}

	if err := s.Database.DeleteFruitByID(id); err != nil {
		return err
	}

	return c.JSON(http.StatusOK, "fruit deleted")
}
func main() {
	// Echo instance

	s, err := NewStorage()
	if err != nil {
		log.Fatalln(err)
	}

	server := NewServer(s)
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// Routes
	e.GET("/", server.Home)
	e.POST("/fruit", server.InsertFruitHandler)
	e.DELETE("/fruit/:id", server.DeleteFruitHandler)
	// e.GET("/fruit", server.GetFruitHandler)
	// Start server
	e.Logger.Fatal(e.Start(":1323"))
}

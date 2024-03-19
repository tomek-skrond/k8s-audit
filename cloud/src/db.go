package main

import (
	"fmt"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type Fruit struct {
	Id     int    `gorm:"primary_key"`
	Name   string `gorm:"name"`
	Taste  string `gorm:"taste"`
	Rating string `gorm:"rating"`
}

type Storage struct {
	DB *gorm.DB
}

func NewStorage() (*Storage, error) {
	user := os.Getenv("POSTGRES_USER")
	pass := os.Getenv("POSTGRES_PASSWORD")
	host := os.Getenv("POSTGRES_HOST")
	db_name := os.Getenv("POSTGRES_DB")

	// fmt.Println(user, pass, host, db_name)
	sslmode := os.Getenv("SSLMODE")

	connStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=5432 sslmode=%s TimeZone=Europe/Warsaw",
		host,
		user,
		pass,
		db_name,
		sslmode)

	d, err := gorm.Open(postgres.Open(connStr), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		log.Fatalln(err)
		return nil, err
	}

	d.AutoMigrate(&Fruit{})
	return &Storage{
		DB: d,
	}, nil
}

// / CRUD
func (s Storage) InsertFruit(newFruitReq Fruit) error {

	if err := s.DB.Create(&newFruitReq).Error; err != nil {
		fmt.Println("db error11111111111111111111111")
		return err
	}

	return nil
}

func (s Storage) GetFruit() ([]Fruit, error) {
	fruits := []Fruit{}

	response := s.DB.Find(&fruits)
	if response.Error != nil {
		return nil, response.Error
	}

	return fruits, nil
}

func (s Storage) DeleteFruitByID(idToDelete int) error {
	fruitToDelete := &Fruit{}
	fruitToDelete.Id = idToDelete

	if err := s.DB.Where("id = ?", idToDelete).First(fruitToDelete).Error; err != nil {
		fmt.Println("gggggggggg")
		return err
	}

	s.DB.Delete(&fruitToDelete)

	return nil
}

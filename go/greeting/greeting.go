package main

import (
	"fmt"
	"C"
)

func main(){

}

//export hello
func hello(msg string) {
	fmt.Println("go func hello called, print:",msg)
}

//export hi
func hi() string {
	return "hi, this is gopher"
}

//export echo
func echo(msg string) string {
	fmt.Println("go func echo called, print:",msg)
	return msg
}

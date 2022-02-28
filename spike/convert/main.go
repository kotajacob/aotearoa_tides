package main

// reads each file in the "csv" directory, parses the tidal data, and
// rewrites it in a cleaner format in the "json" directory.

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unicode"
)

// TZ is the timezone for the imported times.
const TZ = "NZ"

// Tide represents a LINZ tidal height at a specific time.
type Tide struct {
	Time   time.Time
	Height float64
}

func main() {
	// List files in "csv" directory.
	csvs, err := os.ReadDir("csv")
	if err != nil {
		log.Fatalln(err)
	}

	for _, csv := range csvs {
		f, err := os.Open(filepath.Join("csv", csv.Name()))
		defer f.Close()
		if err != nil {
			log.Fatalln(err)
		}

		// Read csv File and store [][]string records.
		records, err := getRecords(f)
		if err != nil {
			fmt.Printf("%v\n", err)
			os.Exit(1)
		}

		// Convert [][]string records to []Tide.
		var tides []Tide
		for _, record := range records {
			err := parseRecord(&tides, record)
			if err != nil {
				fmt.Printf("%v\n", err)
				os.Exit(1)
			}
		}

		// Write tides to json files.
		j, err := json.Marshal(tides)
		if err != nil {
			log.Fatalln(err)
		}

		// Swap extension to json.
		name := strings.ReplaceAll(csv.Name(), "csv", "json")
		err = os.WriteFile(filepath.Join("json", name), j, 0644)
		if err != nil {
			log.Fatalln(err)
		}
	}
}

// getRecords reads and parses a csv file from LINZ with tidal data into
// [][]string and skips the first 3 metadata lines.
func getRecords(f *os.File) ([][]string, error) {
	reader := csv.NewReader(f)
	reader.FieldsPerRecord = -1 // allows for variable number of fields
	// skip the first 3 lines
	for i := 0; i < 3; i++ {
		reader.Read()
	}
	records, err := reader.ReadAll()
	return records, err
}

// parseRecord reads a []string representing a line in the csv file and adds
// them to a slice of Tides in order from oldest to newest.
func parseRecord(tides *[]Tide, record []string) error {
	// Each record represents a single date, but contains multiple tides at
	// different times.
	date, err := getDate(record[3], record[2], record[0])
	if err != nil {
		return err
	}
	for r := 4; r < len(record); r += 2 {
		// some days have less tides
		if record[r] == "" {
			break
		}
		duration, err := getDuration(record[r])
		t := date.Add(duration)
		if err != nil {
			return err
		}
		height, err := strconv.ParseFloat(record[r+1], 64)
		if err != nil {
			return err
		}
		tide := Tide{t, height}
		*tides = append(*tides, tide)
	}
	return nil
}

// getDate takes the year, month, day strings from the CSV file and returns a
// time.Time value with the correct timezone.
func getDate(year, month, day string) (time.Time, error) {
	loc, _ := time.LoadLocation(TZ) // Timezone isn't included in the CSV
	month = fmt.Sprintf("%02s", month)
	day = fmt.Sprintf("%02s", day)
	t, err := time.ParseInLocation("20060102", year+month+day, loc)
	return t, err
}

// getDuration takes a string in the hh:mm format and returns a time.Duration.
// The string is split into slice t and then formatted into the
// time.ParseDuration format.
func getDuration(s string) (time.Duration, error) {
	f := func(c rune) bool {
		return !unicode.IsLetter(c) && !unicode.IsNumber(c)
	}
	t := strings.FieldsFunc(s, f)
	duration, err := time.ParseDuration(fmt.Sprintf("%vh%vm", t[0], t[1]))
	return duration, err
}

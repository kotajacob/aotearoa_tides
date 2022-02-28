package main

// download source csv files from linz from a list of ports.

import (
	"crypto/tls"
	"io"
	"log"
	"net/http"
	"os"
)

const base = "https://www.linz.govt.nz/docs/hydro/tidal-info/tide-tables/maj-ports/csv/"

var ports = []string{
	"Akaroa",
	"Anawhata",
	"Auckland",
	"Ben Gunn Wharf",
	"Bluff",
	"Castlepoint",
	"Deep Cove",
	"Dunedin",
	"Flour Cask Bay",
	"Fresh Water Basin",
	"Gisborne",
	"Green Island",
	"Havelock",
	"Huruhi Harbour",
	"Jackson Bay",
	"Kaikoura",
	"Kaingaroa",
	"Kaiteriteri",
	"Kaituna River",
	"Kawhia",
	"Korotiti Bay",
	"Leigh",
	"Lottin Point (Wakatiri)",
	"Lyttelton",
	"Mana Marina",
	"Man O' War Bay",
	"Mapua",
	"Marsden Point",
	"Matiatia Bay",
	"Napier",
	"Nelson",
	"North Cape (Otou)",
	"Oamaru",
	"Oban",
	"Omokoroa",
	"Onehunga",
	"Opotiki Wharf",
	"Opua",
	"Owenga",
	"Paratutae Island",
	"Picton",
	"Port Chalmers",
	"Port Ohope Wharf",
	"Port Taranaki",
	"Pouto Point",
	"Raglan",
	"Rocky Point",
	"Scott Base",
	"Spit Wharf",
	"Sumner",
	"Tarakohe",
	"Tauranga",
	"Timaru",
	"Waiorua Bay",
	"Waitangi",
	"Whanganui River Entrance",
	"Welcombe Bay",
	"Wellington",
	"Westport",
	"Whakatane",
	"Whangarei",
	"Whangaroa",
	"Whitianga",
}

func main() {
	for _, port := range ports {
		year := os.Args[1]

		tr := &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		}
		client := &http.Client{Transport: tr}

		url := base + port + " " + year
		resp, err := client.Get(url)
		if err != nil {
			log.Fatal(err)
		}

		b, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			log.Fatal(err)
		}
		os.WriteFile("csv/"+port+".csv", b, 0644)
	}
}

import 'package:flutter/material.dart';

import 'port-page.dart';

void main() {
  runApp(const TideApp());
}

const Map<String, String> ports = {
  "Akaroa": "json/akaroa.json",
  "Anawhata": "json/anawhata.json",
  "Auckland": "json/auckland.json",
  "Ben Gunn Wharf": "json/ben_gunn_wharf.json",
  "Bluff": "json/bluff.json",
  "Castlepoint": "json/castlepoint.json",
  "Deep Cove": "json/deep_cove.json",
  "Dunedin": "json/dunedin.json",
  "Flour Cask Bay": "json/flour_cask_bay.json",
  "Fresh Water Basin": "json/fresh_water_basin.json",
  "Gisborne": "json/gisborne.json",
  "Green Island": "json/green_island.json",
  "Havelock": "json/havelock.json",
  "Huruhi Harbour": "json/huruhi_harbour.json",
  "Jackson Bay": "json/jackson_bay.json",
  "Kaikoura": "json/kaikoura.json",
  "Kaingaroa": "json/kaingaroa.json",
  "Kaiteriteri": "json/kaiteriteri.json",
  "Kaituna River": "json/kaituna_river.json",
  "Kawhia": "json/kawhia.json",
  "Korotiti Bay": "json/korotiti_bay.json",
  "Leigh": "json/leigh.json",
  "Lottin Point (Wakatiri)": "json/lottin_point_wakatiri.json",
  "Lyttelton": "json/lyttelton.json",
  "Mana Marina": "json/man_o_war_bay.json",
  "Man O' War Bay": "json/mana_marina.json",
  "Mapua": "json/mapua.json",
  "Marsden Point": "json/marsden_point.json",
  "Matiatia Bay": "json/matiatia_bay.json",
  "Napier": "json/napier.json",
  "Nelson": "json/nelson.json",
  "North Cape (Otou)": "json/north_cape_otou.json",
  "Oamaru": "json/oamaru.json",
  "Oban": "json/oban.json",
  "Omokoroa": "json/omokoroa.json",
  "Onehunga": "json/onehunga.json",
  "Opotiki Wharf": "json/opotiki_wharf.json",
  "Opua": "json/opua.json",
  "Owenga": "json/owenga.json",
  "Paratutae Island": "json/paratutae_island.json",
  "Picton": "json/picton.json",
  "Port Chalmers": "json/port_chalmers.json",
  "Port Ohope Wharf": "json/port_ohope_wharf.json",
  "Port Taranaki": "json/port_taranaki.json",
  "Pouto Point": "json/pouto_point.json",
  "Raglan": "json/raglan.json",
  "Rocky Point": "json/rocky_point.json",
  "Scott Base": "json/scott_base.json",
  "Spit Wharf": "json/spit_wharf.json",
  "Sumner": "json/sumner.json",
  "Tarakohe": "json/tarakohe.json",
  "Tauranga": "json/tauranga.json",
  "Timaru": "json/timaru.json",
  "Waiorua Bay": "json/waiorua_bay.json",
  "Waitangi": "json/waitangi.json",
  "Whanganui River Entrance": "json/welcombe_bay.json",
  "Welcombe Bay": "json/wellington.json",
  "Wellington": "json/westport.json",
  "Westport": "json/whakatane.json",
  "Whakatane": "json/whanganui_river_entrance.json",
  "Whangarei": "json/whangarei.json",
  "Whangaroa": "json/whangaroa.json",
  "Whitianga": "json/whitianga.json",
};

class TideApp extends StatelessWidget {
  const TideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aotearoa Tides',
      theme: ThemeData(primarySwatch: Colors.cyan)
          .copyWith(primaryColor: Colors.cyan[800]),
      home: const PortPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PortList extends StatelessWidget {
  const PortList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tiles = ports.keys.map(
      (port) {
        return ListTile(
          title: Text(port),
          onTap: () {
            Navigator.pop(context, port);
          },
        );
      },
    );

    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
        : <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ports'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(children: divided),
    );
  }
}

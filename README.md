# marinelife-crawler

Crawls websites for Marine life (fancy for "fish") and collects latin name and taxonomy to create a DB of 🐠 fish.

It's implemented in Ruby and currently cralws Wikipedia for fish info.

I'm investigating alternative tools like Ruby crawlers.

## Result

Look how awesome the parsing results:

```
$ ./crawl-wikipedia.rb
📊 YAML file contains these:
🍣 Clown triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Balistoides > B. conspicillum)
🍣 Gilded triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Xanthichthys > X. auromarginatus)
🍣 Grey triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Balistes > B. capriscus)
🍣 Lagoon triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Rhinecanthus > R. aculeatus)
🍣 Canthidermis (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > CanthidermisSwainson, 1839)
🍣 Orange-lined triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > BalistapusTilesius, 1820 > B. undulatus)
🍣 Balistes vetula (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Balistes > B. vetula)
🍣 Redtoothed triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > OdonusGistel, 1848 > O. niger)
🍣 Reef triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Rhinecanthus > R. rectangulus)
🍣 Xanthichthys ringens (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Xanthichthys > X. ringens)
🍣 Shark (Animalia > Chordata > Chondrichthyes > )
🍣 Starfish (Animalia > Echinodermata > Asterozoa > AsteroideaBlainville, 1830 > )
🍣 Stone triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Pseudobalistes > P. naufragium)
🍣 Titan triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Balistoides > B. viridescens)
🍣 Triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > BalistidaeA. Risso, 1810 > )
```
==> I've created

## RailsApp

I've created a mini app to showcase the parsed results, a=so you can say there are two layers in this app:
* 🕷️ one worker which can dump the whole wikipedia - which I cna cap in bandwidth and number of results
* one app to visualize them all 💍.

  <img src="https://github.com/palladius/marinelife-crawler/blob/main/doc/Maritime Life App Screenshot.png" alt="Maritime Life App v1.0" align='right' />


## LICENSING

I'm trying to faithfully obey to [Wikpiedia Copyrights](https://en.wikipedia.org/wiki/Wikipedia:Copyrights).

* For images (and media), I'm not going to download the images.
* For pages, I'm going to download and make it explicit that they were downloaded form Wikipedia.

If I'm doing something wrong, please open an issue and suggest a solution and I'm happy to oblige.

## Test toggable README with button

Before details...

<details>
  <summary>This is a fake thing Im using in another repo</summary>

  ## blah blah
  1. Foo
  2. Bar
     * Baz
     * Qux


  ### Some Code
  ```js
  function logSomething(something) {
    console.log('Something', something);
  }
  ```
</details>

After detail.

# Awesome

* i've just learnt I can use Ruby vscode to get to method definition :) See [stackoverflow](https://stackoverflow.com/questions/60658665/navigate-to-ruby-function-definition-in-vs-code).
* Next steps: dockerize and make it slurp the whole internet and feed data into some DB, the rails way :)

# TODOs

* Dockerize, execute indefinitely until it fills the disk :)
* One worker crawls the internet, another parses the info and puts somewhere (possibly a DB with some kind of parsing versioning so same page can have more sophisticated ways of making it thru taxo to the DB: currently taxo is half broken).

# Rails

I didnt want to, but  want to visualize the data, so why not :)

```bash
# Additional opts: -d postgresql
# Time on Mac M1: real    0m30.842s
time rails new rails7-marinelife-app --css bootstrap
cd rails7-marinelife-app &&
  rails g scaffold wiki_animals name:string latin:string title:string wiki_url:string short_taxo:string wiki_description:text internal_description:text parse_version:string picture_url:string
```
# Thanks

I would like to thank and quote:

* **Wikipedia** for doing an amazing job.

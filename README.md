# MarinelifeCrawler

Crawls websites for Marine life (fancy for "fish") and collects latin name and taxonomy to create a DB of 🐠 fish.

It's implemented in Ruby and currently cralws Wikipedia for fish info.

I'm investigating alternative tools like Ruby crawlers.

## TODO

* Use https://github.com/vcr/vcr VCR gem to speed up the crawler tests (also you can crawl offline!): from  googlien VCR tutorial:
    * 1. https://www.learnhowtoprogram.com/ruby-and-rails/authentication-and-authorization/testing-api-calls-with-vcr 
    * 2. https://www.rubyguides.com/2018/12/ruby-vcr-gem/

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
🍣 Shark (Animalia > Chordata > Chondrichthyes > )
🍣 Starfish (Animalia > Echinodermata > Asterozoa > AsteroideaBlainville, 1830 > )
🍣 Stone triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Pseudobalistes > P. naufragium)
🍣 Titan triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > Balistidae > Balistoides > B. viridescens)
🍣 Triggerfish (Animalia > Chordata > Actinopterygii > Tetraodontiformes > BalistidaeA. Risso, 1810 > )
```
==> I've created a rails app to see the results. Also if impatient you can:

```bash
bin/status.sh
STATUS : Lets see how many fish in the Sea
1: 🎣 682 Fish in the bucket (just fished fish).
2: 🍤 283 Crunched fish in the pond (crunched fish).
3: 🍣 428 Fish in Ruby app.
```

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
  <summary>This is how the whole process works</summary>

  ## My first meaningful ETL Pipeline 'PipeFish' 🎏
  1. Crawl wikipedia for new fish: `MAX_STACK_SIZE="500000" bin/crawl-wikipeda-for-fish.rb Nudibranch` (needs a starting fish, like Nudibranch)
  2. Now that you have plenty of local files in `en.wikipedia.org/rubycrawl/`. These are bare dumps from Wikpiedia.
     * this function `smart_wiki_parse_fish()` called by `iterate_through_files_in_directory()` will then populate the .ric.yaml files with extracted info. Note that this is algorithm-dependant and currently very buggy - so make sense to regenerate every now and then :)
     * Still dont know how to trigger this, probably its automatic but if so why do i have 250 yaml and 900 files?!? Probably this:
     * `MAX_IMPORTS=1000 bin//crawl-wikipedia-local-samples.rb`. Increase it to 1000! Bingo! it works!
  3. Enter the RoR app and
     *  `cd cd rails7-marinelife-app/`
     *  `MAX_FILES_PER_DIR=1000 rake db:seed`
     *  This creates a number of Model entries based on this folder:


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

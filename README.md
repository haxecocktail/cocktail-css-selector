[![Build Status](https://travis-ci.org/haxecocktail/cocktail-css-selector.svg?branch=master)](https://travis-ci.org/haxecocktail/cocktail-css-selector)

cocktail-css-selector
=====================

CSS selector matching, parsing and serializing.
This lib is part of the larger [Cocktail project](https://github.com/haxecocktail/cocktail).

## Install

```
haxelib install cocktail-css-selector
```

## Usage

### Selectors parsing

```Haxe

//parser class
import cocktail.selector.SelectorsParser;

//Selectors data structures
import cocktail.selector.SelectorData;

class Main {
  public static function main() {
  
    //parse one or multiple selectors and return them in an array of SelectorVO 
    //(see SelectorData implementation)
    var selectors = SelectorsParser.parse('div, p');
  }
}

```

### Selectors matching

```Haxe

```

# nearBest
Do you want to know the best places around? We'll show you

## App Description

This app was developed as part of the [Altran's](https://www.altran.com/pt/pt-pt/) selection process. It consists of a two-screen app that gathers data from the [Google Places API](https://developers.google.com/places/web-service/intro) and shows you the best rated places around you.

The first screen gives you a list of Categories (Favorites, Restaurants, Shopping Malls, Museums and Hospitals) to choose from. The second screen will give you a list of places from the selected category, showing you the name, rating and the total count of ratings for each place.

### Best Place
The best place for each category is shown differently from the others. Please, take a look at this example:

![](https://mattcbr.github.io/imgs/Projects/Apps/nearBest/best_example.png)

Please note the differences. Each label's background is painted golden in the best place, while in the other ones the background is gray. Also, in the upper left corner there is a icon indicating that that is the best place around.

### Favorites
You can also save your favorite places to have them stored offline whenever you need it. This section will show you how to add/remove a place to/from your favorites and where to find your favorites in the app.

#### Managing your favorites
To add or remove a place to/from your favorites all you need to do is press the favorites icon in the upper right corner of a cell. This icon indicates if a place is saved on your favorites or not. Here is a example of this icon when a place is not saved on your favorites list:

![](https://mattcbr.github.io/imgs/Projects/Apps/nearBest/favorite_empty_example.png)

And here is an example of the same icon when a place is saved on your favorites list

![](https://mattcbr.github.io/imgs/Projects/Apps/nearBest/favorite_full_example.png)

#### Finding your favorites
To find your favorite places all you need to do is tap the "favorites" button on the main screen. The "Favorites" button will be shown whenever you have a place saved on your favorites. Look at the examples below:

![](https://mattcbr.github.io/imgs/Projects/Apps/nearBest/firstScreen_FavOn_rsz.png) ![](https://mattcbr.github.io/imgs/Projects/Apps/nearBest/firstScreen_FavOff_rsz.png)

Note that in the first example the favorites button is shown, because there is at least one place saved in the favorites. In the second example, there is no favorites button, meaning that there are no places saved in the favorites.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

To run this app you will need:
* [Xcode](https://developer.apple.com/xcode/)

You can download the source code manually using GitHub's interface or using the terminal:

```
git clone hhttps://github.com/Mattcbr/nearBest.git
```

## Running the tests

This project only has Unit tests. They are located inside the [nearBestTests](https://github.com/Mattcbr/nearBest/tree/master/nearBestTests) folder. You can run them by using the [Xcode interface](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/05-running_tests.html).

## Built With

* [Swift](https://developer.apple.com/swift/) - The programming language used
* [Cocoapods](https://cocoapods.org/) - Dependency Management
* [AlamoFire](https://github.com/Alamofire/Alamofire) - Used to make API requests
* [FMDB](https://github.com/ccgus/fmdb) - Wrapper to easy the SQLite database usage

## Authors

* **Matheus Castelo**
  - [Website](https://mattcbr.github.io/)
  - [Github](https://github.com/Mattcbr)

# su_pinball
A SketchUp API for designing pinball playfields

The goal of the project is to take a description of a pinball playfield and produce a SketchUp model. The generated model should be as complete as possible, with a view to (eventually) generating a model that can be used by a CNC machine.

To run this code:

 - Copy the entire directory into your SketchUp Plugins Directory (mine is C:\Users\username\Application Data\SketchUp\SketchUp 2016\SketchUp\Plugins\su_pinball)
 - Start SketchUp
 - Open the Ruby Console under Windows/Ruby Console
 - Enter the following into the Ruby Console
```ruby
load 'su_pinball/draw.rb'
```
 - Wait (mine takes about four minutes) 

The file `description.rb` contains the description of the playfield (a list of components and their locations.)

I've included a number of SketchUp models that are included as components in the generated playfield. They are sourced from:

- [Pinball Makers Wiki](http://pinballmakers.com/wiki/index.php/Main_Page) (a highly recommended site for anyone interested in making their own machine)
- [SketchUp's 3D Warehouse](https://3dwarehouse.sketchup.com/user.html?id=0847742093543103665613874)
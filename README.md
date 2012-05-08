# TimeTap

TimeTap helps you track the time you spend coding on each project while in TextMate.

Once it's launched you don't have to bother anymore starting/stopping timers or 
inventing some arbitrary amount of time to fill your fancy time tracker.

## Installation

    gem install time_tap
    
    timetap --install
    
… and visit [localhost:1111](http://localhost:1111/)

<img src="http://f.cl.ly/items/17025fecf7189518cf07/timetap-project-list.png"/>
<img src="http://f.cl.ly/items/7b96ad2f7b49a95fdfd0/timetap-project-page.png"/>


## How it works

TimeTap keeps an eye on the modification time of the frontmost file in TextMate
and tells you how much time you spent on each project. 

If you stop coding for a while while squeezing your brains TimeTap understands. 
TimeTap will consider "coding time" pauses to up to 30 minutes between to saves 
in the same project.

Technically it saves a timestamp+path of the frontmost file in TextMate every 
30 seconds, then it digests all this information in a nice Sinatra webapp.

The server will respond on http://0.0.0.0:1111/.


### Assumptions

* You code on TextMate.
* You save often (like me), at least every 30 minutes.
* You keep your code organized (I use ~/Code as main code folder).




## Customize

TimeTap uses a config file to control where projects are kept, etc. the path is:

    ~/.tap_config

Which can look like this:
    
    root: "~"
    # root is where the logs will be saved
    
    code: Code
    # code is where all your projects live
    
    nested_project_layers: 1
    # see below about nested projects
    
    port: 1111
    # the port on localhost for the web interface
    
    ruby: /usr/bin/ruby
    # the ruby you want to use
    
    textmate:
      projects: ~/Development/Current Projects
      # where you keep your .tmproj files



### About "nested project layers"

TimeTap assumes you keep your projects inside a specific folder, like this:

    ~/Code/
      tap/
      tik_tak/
      tk-win/
      AcmeCorp/
        website/
        intranet/
        
But if you keep your projects grouped in subfolders like this:

    ~/Code/
      Clients/
        AcmeCorp/
          website/
          intranet/
        BetaCorp/
          skunkworks/
      OpenSource/
        project_one/
        timetap/

then, the `nested_project_layers` key tells TimeTap how deep to look for project names inside a hierarchy (in the example a value of 2 will catch `AcmeCorp`, `BetaCorp`, `project_one` and `timetap`).


## How to Contribute

Use it, love it, then...

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


### Running & installing in development

Run `ruby -Ilib bin/timetap` or run 
`rake launcher && launchctl load ~/Library/LaunchAgents` 
to add a plist for OSX's launchd and have it launched automatically at login.

### TODO

- <strike>make it more configurable</strike>
- <strike>gemify (with jeweler)</strike>
- support other text editors, or at least make it easy to do so
- (r)spec it!
- flatten encoding quick-fixes with proper solutions (eat and spit only utf8)
- integration with external (online) time tracking tools
- export to csv (?)


## Credits

- Ryan Wilcox [@rwilcox](https://github.com/rwilcox)


## Related Projects

- [Watch Tower](https://github.com/TechnoGate/watch_tower)
- [Vim TimeTap](https://github.com/rainerborene/vim-timetap)


## Copyright

Copyright © 2009-2012 Elia Schito. See LICENSE for details.

# TimeTap

TimeTap helps you track the time you spend coding on each project while in TextMate.

Once it's launched you don't have to bother anymore starting/stopping timers or 
inventing some arbitrary amount of time to fill your fancy time tracker.

<img src="http://f.cl.ly/items/17025fecf7189518cf07/timetap-project-list.png"/>
<img src="http://f.cl.ly/items/7b96ad2f7b49a95fdfd0/timetap-project-page.png"/>


## How does it work

TimeTap keeps an eye on (tracks) the modification time of the frontmost file 
and tells you how much time you spent on each project. 

If you stop coding for a while while squeezing your brains TimeTap understands. 
TimeTap will consider "coding time" pauses to up to 30 minutes between to saves 
in the same project.

Technically it saves a timestamp+path of the frontmost file in TextMate every 
30 seconds, then it digests all this information in a nice Sinatra webapp.

The server will respond on http://0.0.0.0:1111/.


## Instructions

Run `ruby -Ilib bin/timetap` or run 
`rake launcher && launchctl load ~/Library/LaunchAgents` 
to add a plist for OSX's launchd and have it launched automatically at login.

## Setting up config file

timetap uses a config file to control where projects are kept, etc. Put this config file in `~/.tap_config`.

    cp config.yaml ~/.tap_config

### Keys Explained

    root - where the timetap logs should be saved. Recommended value: ~
    code - where all you project live, in a flat hierachy. 
    nested_project_layers - see below, on nested projects. Default is 1
    

Nested Projects allows you to keep your projects inside a hierarchy, instead of the original assumption of timetap (which is that all projects are flat).

For example, you could keep your directory structure might look like:

    ~/Code/
      Clients/
        AcmeCorp/
          website/
            intranet
        BetaCorp/
          skunkworks/
      OpenSource/
        project_one/
        timetap/

A `nested_project_layers` setting of 2 (in your `.tap_config` file) would mean we track "AcmeCorp", "BetaCorp", and everything under OpenSource, as their own projects
    
## Assumptions

* You code on TextMate.
* You save often (like me), at least every 30 minutes.
* You keep your code organized (I use ~/Code as main code folder).


## TODO

- support other text editors, or at least make it easy to do so
- (r)spec it!
- make it more configurable
- gemify (with jeweler)
- flatten encoding quick-fixes with proper solutions (eat and spit only utf8)
- integration with external (online) time tracking tools
- export to csv (?)


## How to Contribute

Use it, love it, then...

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


## Copyright

Copyright (c) 2009 Elia Schito. See LICENSE for details.

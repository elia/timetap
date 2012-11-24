# TimeTap

TimeTap helps you track the time you spend coding on each project while in TextMate.

Once it's launched you don't have to bother anymore starting/stopping timers or
inventing some arbitrary amount of time to fill your fancy time tracker.

<img src="http://f.cl.ly/items/17025fecf7189518cf07/timetap-project-list.png"/>
<img src="http://f.cl.ly/items/7b96ad2f7b49a95fdfd0/timetap-project-page.png"/>



## Installing

    gem install time_tap

    timetap --install

… and visit [localhost:1111](http://localhost:1111/)

### Installing from source

- Get the codez: `git clone git://github.com/elia/timetap.git`
- Run `bundle exec bin/timetap --install`




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


## Editors

TimeTap works with TextMate, TextMate2 and SublimeText2.
For TM2 and ST2 you need to install specific bundles (in the `vendor/` folder).

### TextMate

Need to do nothing, thanks to `rb-appscript` :)


### TextMate 2

You need to install the bundle in [`vendor/SublimeText2`](https://github.com/elia/timetap/tree/master/vendor/TextMate2)


### SublimeText

You need to install the package in [`vendor/SublimeText2`](https://github.com/elia/timetap/tree/master/vendor/SublimeText2)



## Configuring

TimeTap uses a config file to control where projects are kept, etc. the path is:

    ~/.timetap.config

Which can look like this:

```yaml
port: 1111
# the port on localhost for the web interface

# These are used to identify project root folders
code_folders:
  - ~/Code/MyCompany
  - ~/Code

# It's highly recomended to use 1.9.3
ruby: /Users/elia/.rvm/bin/ruby-1.9.3-p286
```



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


### TODO

- <strike>make it more configurable</strike>
- <strike>gemify (with jeweler)</strike>
- <strike>support other text editors, or at least make it easy to do so</strike>
- (r)spec it!
- flatten encoding quick-fixes with proper solutions (eat and spit only utf8)
- integration with external (online) time tracking tools


## Credits

- Ryan Wilcox [@rwilcox](https://github.com/rwilcox)


## Related Projects

- [Watch Tower](https://github.com/TechnoGate/watch_tower)
- [Vim TimeTap](https://github.com/rainerborene/vim-timetap)


## Copyright

Copyright © 2009-2012 Elia Schito. See LICENSE for details.

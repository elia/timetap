import sublime, sublime_plugin
import os.path

class TimeTapCommand(sublime_plugin.EventListener):
	def on_post_save(self, view):  
		file_name = '~/.timetap.sbl2.current_file'
		path = os.path.expanduser(file_name)
		file = open(path, 'w')
		file.write(view.file_name())
		print '[TimeTap]', view.file_name(), 'just got saved in', file_name

project('openloop', 'vala', 'c')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

executable('openloop',
	sources: [
		'src/colours.vala',
		'src/mimetypes.vala',

		'src/main.vala',
		'src/loop.vala',
		'src/section.vala',
		'src/tile.vala',
		'src/looptile.vala',
		'src/metronome.vala',
		'src/liveplayback.vala',
		'src/eyecandy.vala',

		'src/Views/mainwindow.vala',

		'src/Widgets/loopsourcelist.vala',
		'src/Widgets/bottombar.vala',
		'src/Widgets/metronomectl.vala',
		'src/Widgets/tilegrid.vala',
		'src/Widgets/tilehost.vala',

		'src/Audio/pipeline.vala',
		'src/Audio/sample.vapi',
		'src/Audio/sample.c',
		'src/Audio/samplesrc.vapi',
		'src/Audio/samplesrc.c',
		'src/Audio/samplesink.vapi',
		'src/Audio/samplesink.c',

		'src/Threads/threads.vala',
		'src/Threads/loopimporter.vala',

		'src/DevMode/metronomeinfo.vala',
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gee-0.8'),
		dependency('gtk+-3.0'),
		dependency('granite'),
		dependency('gstreamer-1.0'),
		dependency('gstreamer-audio-1.0'),
		dependency('gstreamer-app-1.0'),
		dependency('gstreamer-pbutils-1.0'),
		dependency('gst-editing-services-1.0'),

		meson.get_compiler('c').find_library('m')	# libm; maths library
	],
	include_directories: include_directories('src/Audio/'),	# We need to tell the C compiler where it can find the headers that the .vapi's refer to
	c_args: [
		'-Wno-deprecated-declarations',
		'-Wno-discarded-qualifiers',
		'-Wno-unused-but-set-variable',
		'-Wno-unused-variable',
		'-Wno-unused-function',
		'-lm',
	],
)

run_target('fetch-vapi',
	command: ['wget', '-P', 'vapi/', 'https://raw.githubusercontent.com/GNOME/vala/master/vapi/gst-editing-services-1.0.vapi']
)

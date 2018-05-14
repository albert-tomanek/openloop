project('openloop', 'vala', 'c')

executable('openloop',
	sources: [
		'src/main.vala',

		'src/tile.vala',
		'src/loop.vala',

		'src/appui.vala',
		'src/tilehost.vala',

		'src/sample.vapi',
		'src/sample.c',
		'src/sampleplayer.vapi',
		'src/sampleplayer.c',
		'src/looptile.vala',
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gtk+-3.0'),
		dependency('gstreamer-1.0'),
		dependency('gstreamer-audio-1.0')
	]
)

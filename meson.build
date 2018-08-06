project('openloop', 'vala', 'c')

executable('openloop',
	sources: [
		'src/appui.vala',
		'src/loop.vala',
		'src/looptile.vala',
		'src/main.vala',
		'src/pipeline.vala',
		'src/sample.vapi',
		'src/sample.c',
		'src/sampleplayer.vapi',
		'src/sampleplayer.c',
		'src/section.vala',
		'src/tile.vala',
		'src/tilegrid.vala',
		'src/tilehost.vala',
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gee-0.8'),
		dependency('gtk+-3.0'),
		dependency('gstreamer-1.0'),
		dependency('gstreamer-audio-1.0'),
	],
	include_directories: include_directories('src/'),	# We need to tell the C compiler where it can find the headers that the .vapi's refer to
	c_args: [
		'-Wno-discarded-qualifiers',
		'-Wno-unused-but-set-variable',
		'-Wno-unused-variable',
		'-Wno-unused-function',
	],
)

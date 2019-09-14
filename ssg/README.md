# IMPORTANT INFORMATION

**This folder is for development ONLY.**
Note, that this is the reason *why* all `require` calls do **not** specify a `"ssg."` prefix, as this folder is not existing inside the final build of the `run.love.` file!

A release should only contain

- an example project folder
- and a completely prepackaged, self containing, standalone love executable (including the `config.json` and `run.love` source code)

Instead the standalone, an alternative distibution might include

- an example project folder
- a demo `config.json`
- a `plugins` directory with demo plugins
- the `./build` & run script
- and a compiled `run.love` source

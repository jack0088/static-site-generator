# IMPORTANT INFORMATION

**This folder is for development ONLY and should not be included in the final realease!**
Note, that this is the reason *why* all `require` calls do **not** specify a `"ssg."` prefix, as this folder does not exist inside the compiled `run.love.` source file!

A release should only contain

- an example project folder
- and a completely pre-packaged, self containing, standalone LÖVE2D executable (that is including the `run.love` source code)

During the development cycle the distibution package includes

- an example project folder with a demo `config.json`, plus a `plugins` directory with demo plugins
- the `./build` & run script, which compiles our source into `run.love` and runs it via LÖVE2D

# Configuration

The SSG does not need a `config.json` file but you can specify one to override its default behaviour or extend it via plugins.

The `render` key specifies the entrypoint for the generation.
The given folder will be traversed and all placeholders will be replaced with their corresponding values.
Default value is `"./"` which is the current folder of your website project.

The `publish` key defines the output folder of the final, rendered HTML that you need to upload to your host.
Default value is `"www"`.

Special functionality can be provided to the SSG via Lua plugins.
The key `plugins` is the place to reference your plugins.
*However, right now this topic is WIP...*


# Build & Run

The SSG comes pre-packaged in a LÖVE2D standalone application wrapper.
You run the SSG application and drop-in the folder, that holds your website project via drag & drop.
As we learned, this project folder contains all the content to build the website from - including an optional `config.json` file that specifies which directory inside your project to use for what purpose or which plugins to run during the generation.

*Right now we are in development, so the standalone app is not available yet, but instead some scripts that build and run the project!*

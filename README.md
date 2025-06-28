# Help Helper

```sh
#             __         __               
#            / /_  ___  / /___            
#           / __ \/ _ \/ / __ \           
#          / / / /  __/ / /_/ /           
#         /_/ /_/\___/_/ .___/            
#             __      /_/__               
#            / /_  ___  / /___  ___  _____
#           / __ \/ _ \/ / __ \/ _ \/ ___/
#          / / / /  __/ / /_/ /  __/ /    
#         /_/ /_/\___/_/ .___/\___/_/     
#                     /_/                      
```

A suite of helper functions for helping you write your help text. Helpful.
Use Help Helper's modular system to easily generate automatically aligned and formatted help text in your fish scripts.
No more `echo`ing messy multiline string literals.

Written purely in [fish](https://github.com/fish-shell/fish-shell)!

## Installation
Requires [fish](https://github.com/fish-shell/fish-shell).
```sh
git clone git@github.com:chloebubble/fish-help-helper.git
cd fish-help-helper
chmod +x install.fish
./install.fish
```

## Usage
Within your fish script or function, you can call `generate_help` with your desired options, and it will generate and print your help text on the fly.

Syntax:
```sh
generate_help \
	--usage <text> # Your basic usage template \
	--option <flag> <description> # Add an option with its description \
	--section <title> <item 1> <item 1 description> <item 2> <item 2 description> ... # Add an info section with a list of entries
```

Example usage (best paired with fish's `argparse`):
```sh
function my_function
	argparse 'h/help' 'v/verbose' 'b/batches=' -- $argv

	if set -q _flag_help
		generate_help \
			--usage "my_function [OPTIONS] <target>" \
			--option "-h, --help" "Shows this help screen and exits." \
			--option "-v, --verbose" "Enables verbose output." \
			--option "-b, --batches" "Number of batches to run." \
			--section BATCHES 1 "Batches of more than 1 will run in parallel." 2 "It's not my fault if you run out of memory."
	end

	# function logic goes here
end
```
The above will result in this output when `my_function --help` is run:
```sh
USAGE: my_function [OPTIONS] <target>

OPTIONS:
  -h, --help                                   Shows this help screen and exits.
  -v, --verbose                                Enables verbose output.
  -b, --batches                                Number of batches to run.

BATCHES:
  1                                            Batches of more than 1 will run in parallel.
  2                                            It's not my fault if you run out of memory.
```

			

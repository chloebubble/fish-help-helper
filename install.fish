#!/usr/bin/env fish

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

   

# setup script
# run this once to install the help helper system

set help_functions_dir ~/.config/fish/functions/help_system
mkdir -p $help_functions_dir

echo "Installing Fish help system functions to $help_functions_dir..."

function __help_init
    set -g __help_usage ""
    set -g __help_description ""
    set -g __help_options
    set -g __help_sections
end

function __help_add_usage
    set -g __help_usage $argv[1]
end

function __help_add_description
    set -g __help_description $argv[1]
end

function __help_add_option
    set -a __help_options $argv[1] $argv[2]
end

# add a custom section with title and key-value pairs
function __help_add_section
    set section_title $argv[1]
    set -a __help_sections $section_title
    
    # add key-value pairs (skip first argument which is title)
    for i in (seq 2 2 (count $argv))
        if test $i -le (count $argv)
            set key $argv[$i]
            set desc $argv[(math $i + 1)]
            set -a __help_sections $key $desc
        end
    end
end

# calculate maximum width of the first column for alignment
function __help_calc_max_width
    set max_width 0
    
    # check options width
    for i in (seq 1 2 (count $__help_options) 2>/dev/null)
        set opt_len (string length -- $__help_options[$i])
        if test $opt_len -gt $max_width
            set max_width $opt_len
        end
    end
    
    # check sections width (only if sections exist)
    if set -q __help_sections; and test (count $__help_sections) -gt 0
        set in_section false
        for i in (seq 1 (count $__help_sections))
            set item $__help_sections[$i]
            
            # check if this is a section title
            if test $in_section = false
                set in_section true
                continue
            end
            
            # this is a key in a key-value pair
            set key_len (string length -- $item)
            if test $key_len -gt $max_width
                set max_width $key_len
            end
            
            # skip the description (next item)
            set i (math $i + 1)
            
            # check if we've reached the end or next section
            if test $i -ge (count $__help_sections)
                set in_section false
            else if test (math $i + 1) -le (count $__help_sections)
                set next_idx (math $i + 1)
                if test $next_idx -eq (count $__help_sections)
                    set in_section false
                end
            end
        end
    end
    
    echo $max_width
end

# render complete help text with proper alignment
function __help_render
    set max_width (__help_calc_max_width)
    set padding (math $max_width + 4)
    
    # print usage
    if test -n "$__help_usage"
        echo "USAGE: $__help_usage"
        echo
    end
    
    # print description
    if test -n "$__help_description"
        echo $__help_description
        echo
    end
    
    # print options
    if test (count $__help_options) -gt 0
        echo "OPTIONS:"
        for i in (seq 1 2 (count $__help_options))
            set opt $__help_options[$i]
            set desc $__help_options[(math $i + 1)]
            printf "  %-*s %s\n" $max_width $opt $desc
        end
        echo
    end
    
    # print custom sections (only if sections exist)
    if set -q __help_sections; and test (count $__help_sections) -gt 0
        set i 1
        while test $i -le (count $__help_sections)
            set section_title $__help_sections[$i]
            echo "$section_title:"
            set i (math $i + 1)
            
            # print key-value pairs for this section
            while test $i -le (count $__help_sections)
                set key $__help_sections[$i]
                set desc $__help_sections[(math $i + 1)]
                
                # check if this might be a new section title
                if test (math $i + 1) -gt (count $__help_sections)
                    break
                end
                
                # check if the "description" looks like a section title
                if string match -qr '^[A-Z][A-Z0-9 ._-]*:?$' $desc
                    break
                end
                
                printf "  %-*s %s\n" $max_width $key $desc
                set i (math $i + 2)
            end
            echo
        end
    end
end

function generate_help --description "Generate and display POSIX-style help text"
    # check for help flag first
    for arg in $argv
        if begin test "$arg" = "-h"; or test "$arg" = "--help"; end
            # check if we can call ourselves recursively (avoid infinite loop)
            if functions -q generate_help; and test (status current-function) != "generate_help"
                generate_help \
                    --usage "generate_help [OPTIONS]" \
                    --description "Generate and display POSIX-style help text with automatic alignment" \
                    --option "-h, --help" "Show this help message and exit" \
                    --option "-u, --usage <text>" "Set the usage line" \
                    --option "-d, --description <text>" "Set the description paragraph" \
                    --option "-o, --option <flag> <desc>" "Add a command option with description" \
                    --section "EXAMPLES" \
                        "Basic usage" "generate_help --usage \"cmd [opts]\" --option \"-h\" \"help\"" \
                        "With section" "generate_help --section \"LEVELS\" \"1\" \"basic\" \"2\" \"advanced\""
            else
                # fallback to basic help if recursive call would cause issues
                echo "USAGE: generate_help [OPTIONS]"
                echo ""
                echo "Generate and display POSIX-style help text with automatic alignment"
                echo ""
                echo "OPTIONS:"
                echo "  -h, --help              Show this help message and exit"
                echo "  -u, --usage <text>      Set the usage line"  
                echo "  -d, --description <text> Set the description paragraph"
                echo "  -o, --option <flag> <desc> Add a command option with description"
            end
            return 0
        end
    end
    
    __help_init
    
    set i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --usage -u
                set i (math $i + 1)
                __help_add_usage $argv[$i]
                
            case --description -d
                set i (math $i + 1)
                __help_add_description $argv[$i]
                
            case --option -o
                set i (math $i + 1)
                set flag $argv[$i]
                set i (math $i + 1)
                set desc $argv[$i]
                __help_add_option $flag $desc
                
            case --section -s
                set i (math $i + 1)
                set section_title $argv[$i]
                set section_args $section_title
                
                # collect key-value pairs until next flag or end
                set i (math $i + 1)
                while test $i -le (count $argv)
                    if string match -q -- '--*' $argv[$i]
                        set i (math $i - 1)  # back up to process this flag
                        break
                    end
                    set -a section_args $argv[$i]
                    set i (math $i + 1)
                end
                
                __help_add_section $section_args
                
            case '*'
                echo "generate_help: unknown option '$argv[$i]'" >&2
                return 1
        end
        set i (math $i + 1)
    end
    
    __help_render
end


# save all functions to the help helper system directory
echo "Saving helper functions..."

funcsave __help_init -d $help_functions_dir
funcsave __help_add_usage -d $help_functions_dir  
funcsave __help_add_description -d $help_functions_dir
funcsave __help_add_option -d $help_functions_dir
funcsave __help_add_section -d $help_functions_dir
funcsave __help_calc_max_width -d $help_functions_dir
funcsave __help_render -d $help_functions_dir
funcsave generate_help -d $help_functions_dir

# check the fish config file for the line that sources our functions
grep -q "# help helper functions
for i in  ~/\.config/fish/functions/help_system/\*\.fish; source \$i; end" ~/.config/fish/config.fish

# add the line if not
if not test $status = 0
    echo  "# help helper functions
for i in  ~/.config/fish/functions/help_system/*.fish; source \$i; end" >> ~/.config/fish/config.fish 
end

echo "✓ Fish help system functions installed successfully!"
echo "  Location: $help_functions_dir"
echo "  Functions: __help_init, __help_add_usage, __help_add_description,"
echo "             __help_add_option, __help_add_section, __help_render"
echo ""
echo "You can now use these functions in your main function files."

string repeat -n (math $COLUMNS/2) =
sleep 0.3

echo "For help on usage syntax, run generate_help --help."
read -l -P "Would you like to run it now? (Y/n): " show_help

switch $show_help
    case y Y ''
        string repeat -n (math $COLUMNS/2) =
        echo
        generate_help --help
    case n N '*'
        # nothing
end

string repeat -n (math $COLUMNS/2) =
sleep 0.3

echo "Installation complete.
To use Help Helper, you will need to restart fish or run:
    source ~/.config/fish/config.fish"

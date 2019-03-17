function ytdl
    set Music "$HOME/Music"
    set music "$HOME/music"

    if not test -d $Music -o -d $music
        mkdir $HOME/Music
        set out_dir "$HOME/Music/"
    else if test -d $Music -a -d $music
        set out_dir "$HOME/Music/"
    else if test -d $Music
        set out_dir "$HOME/Music/"
    else if test -d $music
        set out_dir "$HOME/Music/"
    else
        set out_dir "$HOME/Music/"
    end

    echo -e "\n[*] Output location directory: $out_dir\n"
    youtube-dl --extract-audio --audio-format mp3 -o "$out_dir/%(title)s.%(ext)s" $argv
    echo ""
end

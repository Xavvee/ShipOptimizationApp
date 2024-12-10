using Gtk
using TOML

# Upewnij się, że importowane są wszystkie potrzebne komponenty
const Label = Gtk.Label
const Entry = Gtk.Entry
const Button = Gtk.Button
const GtkBox = Gtk.Box
const GtkWindow = Gtk.Window

# Funkcje do obsługi konfiguracji
function load_config(path::String)
    return TOML.parsefile(path)
end

function save_config(path::String, config::Dict)
    open(path, "w") do file
        TOML.print(file, config)
    end
end

# Ścieżka do pliku konfiguracyjnego
const CONFIG_PATH = joinpath(@__DIR__, "configuration", "config.toml")

function create_gui()
    # Wczytanie konfiguracji
    config = load_config(CONFIG_PATH)

    # Tworzenie okna
    win = GtkWindow("Configuration Editor", 600, 400)
    main_box = GtkBox(:v)

    # Przechowywanie pól tekstowych
    fields = Dict()

    # Generowanie sekcji
    for (section, params) in config
        section_label = Label(section)
        push!(main_box, section_label)

        section_box = GtkBox(:v)
        for (key, value) in params
            hbox = GtkBox(:h)
            label = Label(key)
            
            # Tworzenie GtkEntry bez argumentu w konstruktorze
            entry = Entry()
            set_gtk_property!(entry, :text, string(value))  # Ustawianie wartości jako tekst w GtkEntry
            
            push!(hbox, label)
            push!(hbox, entry)
            push!(section_box, hbox)

            # Zapisywanie referencji do pól tekstowych
            fields["$section.$key"] = entry
        end
        push!(main_box, section_box)
    end

    # Dodanie przycisku "Start"
    start_button = Button("Start")
    push!(main_box, start_button)

    # Funkcja obsługująca kliknięcie przycisku
    function on_start_button_clicked(widget)
        # Aktualizacja konfiguracji na podstawie pól tekstowych
        for (key, entry) in fields
            # Debugging: Check the type of entry
            println("Entry for $key is of type: ", typeof(entry))
            
            section, param = split(key, ".")
            
            # Ensure that entry is indeed a Gtk.Entry
            if typeof(entry) <: Gtk.Entry
                
                # źleeeeeeeeeeeeeee
                text = entry["text"]  # Extract the text from the GtkEntry widget
                println("Text from entry: $text")  # Print the text
            else
                println("Warning: entry for $key is not a Gtk.Entry.")
                continue  # Skip this field if it's not a Gtk.Entry
            end

            println("parsowanie")

        end
    
        # Zapis konfiguracji
        save_config(CONFIG_PATH, config)
    
        # Uruchomienie głównej aplikacji
        println("Starting application...")
        run(`julia -t 4 main.jl`)
    end
    
    

    signal_connect(on_start_button_clicked, start_button, :clicked)

    # Dodanie wszystkiego do okna i pokazanie
    push!(win, main_box)
    showall(win)
end

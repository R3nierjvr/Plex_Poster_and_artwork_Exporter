import tkinter as tk
from tkinter import ttk, messagebox
from plexapi.server import PlexServer
import os, requests, threading

def scan_library():
    url = url_entry.get().strip()
    token = token_entry.get().strip()
    library = library_entry.get().strip()

    output_box.insert(tk.END, f"Scanning library: {library}...\n")
    try:
        plex = PlexServer(url, token)
        section = plex.library.section(library)
        count = len(section.all())
        output_box.insert(tk.END, f"Library \"{section.title}\" contains {count} items.\n")
    except Exception as e:
        output_box.insert(tk.END, f"[ERROR] {str(e)}\n")

def start_export():
    def do_export():
        url = url_entry.get().strip()
        token = token_entry.get().strip()
        library = library_entry.get().strip()
        output_box.insert(tk.END, f"Starting export for: {library}...\n")
        progress_bar['value'] = 0
        try:
            plex = PlexServer(url, token)
            section = plex.library.section(library)
            items = section.all()
            total = len(items)
            for index, item in enumerate(items):
                try:
                    media_path = item.media[0].parts[0].file
                    base = os.path.dirname(media_path)
                    poster_url = f"{url}{item.thumb}"
                    fanart_url = f"{url}{item.art}"

                    def download_image(img_url, path):
                        headers = {'X-Plex-Token': token}
                        r = requests.get(img_url, headers=headers, stream=True)
                        if r.status_code == 200:
                            with open(path, 'wb') as f:
                                for chunk in r.iter_content(1024):
                                    f.write(chunk)
                            output_box.insert(tk.END, f"[OK] Saved: {path}\n")
                        else:
                            output_box.insert(tk.END, f"[FAILED] Could not download from {img_url}\n")

                    output_box.insert(tk.END, f"Processing: {item.title}\n")
                    download_image(poster_url, os.path.join(base, 'poster.jpg'))
                    download_image(fanart_url, os.path.join(base, 'fanart.jpg'))

                except Exception as e:
                    output_box.insert(tk.END, f"[ERROR] {item.title} -> {e}\n")
                progress = int(((index + 1) / total) * 100)
                progress_bar['value'] = progress
                root.update_idletasks()
        except Exception as e:
            output_box.insert(tk.END, f"[ERROR] {str(e)}\n")

    threading.Thread(target=do_export).start()

# === UI Setup ===
root = tk.Tk()
root.title("Plex Poster Exporter (Linux)")
root.geometry("500x500")

tk.Label(root, text="Plex Server URL:").pack()
url_entry = tk.Entry(root, width=50)
url_entry.insert(0, "http://localhost:32400")
url_entry.pack()

tk.Label(root, text="Plex Token:").pack()
token_entry = tk.Entry(root, width=50)
token_entry.pack()

tk.Label(root, text="Library Name:").pack()
library_entry = tk.Entry(root, width=50)
library_entry.pack()

output_box = tk.Text(root, height=12, bg="white")
output_box.pack(pady=10)

progress_bar = ttk.Progressbar(root, orient="horizontal", length=400, mode="determinate")
progress_bar.pack(pady=5)

btn_frame = tk.Frame(root)
btn_frame.pack()

tk.Button(btn_frame, text="Scan Library", command=scan_library).grid(row=0, column=0, padx=10)
tk.Button(btn_frame, text="Start Export", command=start_export).grid(row=0, column=1, padx=10)

root.mainloop()

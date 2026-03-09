import requests
import tkinter as tk
from tkinter import messagebox
import random
import math
import os
import sys

# === LOGIN MANTIĞI (İstediğin POST İsteği) ===
def check_login(email, password):
    url = "https://smsonay.app/panel/ajax/login"
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36",
        "Pragma": "no-cache",
        "Accept": "*/*",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    
    payload = {
        "email": email,
        "password": password
    }
    
    try:
        response = requests.post(url, data=payload, headers=headers)
        res_text = response.text
        
        # KEYCHECK Kısmı
        if '{"success":true,"' in res_text:
            return True, "Giriş Başarılı!"
        elif 'Giri\\u015f Ba\\u015far\\u0131s\\u0131z!' in res_text or '{"success":false,' in res_text:
            return False, "Hatalı Bilgiler!"
        else:
            return False, "Sunucudan geçersiz yanıt geldi."
    except Exception as e:
        return False, f"Bağlantı Hatası: {str(e)}"

# === GÖRSEL VE FRONTEND (Aşırı Yoğun WASD) ===
def start_ui():
    app = tk.Tk()
    app.title("SMS Onay - Bridge Duel")
    app.geometry("500x400")
    app.configure(bg="#050505")

    # Full Screen Canvas (WASD Yazıları İçin)
    canvas = tk.Canvas(app, bg="#050505", highlightthickness=0)
    canvas.place(relx=0, rely=0, relwidth=1, relheight=1)

    # Login Kutusu
    frame = tk.Frame(app, bg="#0e0e0e", bd=1, relief="flat")
    frame.place(relx=0.5, rely=0.5, anchor="center", width=300, height=250)

    tk.Label(frame, text="SMSONAY LOGIN", fg="white", bg="#0e0e0e", font=("Arial", 12, "bold")).pack(pady=10)
    
    user_ent = tk.Entry(frame, bg="#151515", fg="white", insertbackground="white", relief="flat")
    user_ent.insert(0, "Email")
    user_ent.pack(pady=10, ipady=5, padx=20, fill="x")

    pass_ent = tk.Entry(frame, bg="#151515", fg="white", insertbackground="white", relief="flat", show="*")
    pass_ent.insert(0, "Şifre")
    pass_ent.pack(pady=10, ipady=5, padx=20, fill="x")

    def run_login():
        success, msg = check_login(user_ent.get(), pass_ent.get())
        if success:
            messagebox.showinfo("Başarılı", msg)
        else:
            messagebox.showerror("Hata", msg)

    tk.Button(frame, text="GİRİŞ YAP", bg="#6366f1", fg="white", relief="flat", command=run_login).pack(pady=20, fill="x", padx=20)

    # --- GERÇEK "HER YERDE" WASD SİSTEMİ (200 Adet) ---
    particles = []
    colors = ["#111", "#1a1a1a", "#222", "#2a2a2a", "#333"]
    
    for _ in range(200): # Sayıyı iyice abarttım, her yer dolacak
        size = random.randint(8, 25)
        p = canvas.create_text(random.randint(0, 500), random.randint(0, 400), 
                               text="WASD", font=("Arial", size, "bold"), 
                               fill=random.choice(colors))
        particles.append([p, random.uniform(-1, 1), random.uniform(-1.5, -0.5)])

    def animate():
        mx, my = app.winfo_pointerx() - app.winfo_rootx(), app.winfo_pointery() - app.winfo_rooty()
        for p in particles:
            canvas.move(p[0], p[1], p[2])
            pos = canvas.coords(p[0])
            if not pos: continue
            
            # Mouse itme
            dist = math.sqrt((pos[0]-mx)**2 + (pos[1]-my)**2)
            if dist < 100:
                canvas.move(p[0], (pos[0]-mx)/10, (pos[1]-my)/10)

            # Ekran dışı kontrolü
            if pos[1] < -20: canvas.coords(p[0], random.randint(0, 500), 420)
        
        canvas.tag_lower("all")
        app.after(20, animate)

    animate()
    app.mainloop()

if __name__ == "__main__":
    start_ui()

import tkinter as tk

root = tk.Tk()
root.title("App v1.0")
root.geometry("300x150")

label = tk.Label(root, text="Merhaba dayı 😎\nBu app.py çalışıyor", font=("Arial", 12))
label.pack(expand=True)

root.mainloop()

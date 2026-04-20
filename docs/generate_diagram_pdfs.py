from __future__ import annotations

from pathlib import Path
from typing import Iterable
import math

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
SCREENSHOTS = DOCS / "screenshots"
LOGO_PATH = ROOT / "backend-web" / "src" / "main" / "webapp" / "assets" / "img" / "wsu_logo.png"

PAGE_SIZE = (3508, 2480)  # A4 landscape at 300 DPI
MARGIN_X = 140
MARGIN_Y = 110

COLORS = {
    "bg": "#F6F7F9",
    "panel": "#FFFFFF",
    "ink": "#162033",
    "muted": "#4B5563",
    "border": "#B8C1CC",
    "primary": "#213555",
    "secondary": "#3E5879",
    "accent": "#6C4B3B",
    "soft_blue": "#E8EEF5",
    "soft_teal": "#E6EEF0",
    "soft_red": "#F3E9E6",
    "soft_gold": "#F5F0E3",
    "shadow": "#D9E0E8",
}


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = []
    if bold:
        candidates.extend(
            [
                r"C:\Windows\Fonts\timesbd.ttf",
                r"C:\Windows\Fonts\georgiab.ttf",
                r"C:\Windows\Fonts\arialbd.ttf",
                r"C:\Windows\Fonts\segoeuib.ttf",
                r"C:\Windows\Fonts\calibrib.ttf",
            ]
        )
    candidates.extend(
        [
            r"C:\Windows\Fonts\times.ttf",
            r"C:\Windows\Fonts\georgia.ttf",
            r"C:\Windows\Fonts\arial.ttf",
            r"C:\Windows\Fonts\segoeui.ttf",
            r"C:\Windows\Fonts\calibri.ttf",
        ]
    )

    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size=size)
    return ImageFont.load_default()


TITLE_FONT = load_font(66, bold=True)
SUBTITLE_FONT = load_font(30)
H1_FONT = load_font(42, bold=True)
H2_FONT = load_font(30, bold=True)
BODY_FONT = load_font(25)
SMALL_FONT = load_font(21)
TINY_FONT = load_font(18)


def text_size(draw: ImageDraw.ImageDraw, text: str, font) -> tuple[int, int]:
    left, top, right, bottom = draw.multiline_textbbox((0, 0), text, font=font, spacing=6)
    return right - left, bottom - top


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font, max_width: int) -> str:
    words = text.split()
    if not words:
        return ""

    lines: list[str] = []
    current = words[0]
    for word in words[1:]:
        candidate = current + " " + word
        if text_size(draw, candidate, font)[0] <= max_width:
            current = candidate
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return "\n".join(lines)


def draw_header(draw: ImageDraw.ImageDraw, title: str, subtitle: str) -> None:
    draw.rounded_rectangle(
        (MARGIN_X, MARGIN_Y, PAGE_SIZE[0] - MARGIN_X, MARGIN_Y + 190),
        radius=36,
        fill=COLORS["panel"],
        outline=COLORS["border"],
        width=3,
    )

    if LOGO_PATH.exists():
        logo = Image.open(LOGO_PATH).convert("RGBA")
        logo.thumbnail((120, 120))
        temp = Image.new("RGBA", PAGE_SIZE, (0, 0, 0, 0))
        temp.paste(logo, (MARGIN_X + 28, MARGIN_Y + 32), logo)
        draw._image.alpha_composite(temp)

    draw.text((MARGIN_X + 170, MARGIN_Y + 28), title, fill=COLORS["ink"], font=TITLE_FONT)
    draw.text((MARGIN_X + 172, MARGIN_Y + 106), subtitle, fill=COLORS["muted"], font=SUBTITLE_FONT)
    draw.line((MARGIN_X + 170, MARGIN_Y + 146, PAGE_SIZE[0] - MARGIN_X - 28, MARGIN_Y + 146), fill=COLORS["border"], width=2)


def draw_footer(draw: ImageDraw.ImageDraw, label: str) -> None:
    footer_y = PAGE_SIZE[1] - 78
    draw.line((MARGIN_X, footer_y - 26, PAGE_SIZE[0] - MARGIN_X, footer_y - 26), fill=COLORS["border"], width=2)
    draw.text((MARGIN_X, footer_y), label, fill=COLORS["muted"], font=SMALL_FONT)


def panel(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], title: str | None = None, fill: str = COLORS["panel"]) -> None:
    draw.rounded_rectangle(box, radius=30, fill=fill, outline=COLORS["border"], width=3)
    if title:
        draw.text((box[0] + 26, box[1] + 18), title, fill=COLORS["ink"], font=H2_FONT)


def draw_box_with_text(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    body: str,
    fill: str,
    title_fill: str = COLORS["ink"],
) -> None:
    draw.rounded_rectangle(box, radius=28, fill=fill, outline=COLORS["border"], width=3)
    draw.text((box[0] + 24, box[1] + 20), title, fill=title_fill, font=H2_FONT)
    wrapped = wrap_text(draw, body, BODY_FONT, box[2] - box[0] - 48)
    draw.multiline_text((box[0] + 24, box[1] + 74), wrapped, fill=COLORS["muted"], font=BODY_FONT, spacing=8)


def draw_arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], label: str, color: str = COLORS["primary"]) -> None:
    draw.line((start, end), fill=color, width=8)
    angle = math.atan2(end[1] - start[1], end[0] - start[0])
    arrow_len = 24
    left = (end[0] - arrow_len * math.cos(angle - math.pi / 6), end[1] - arrow_len * math.sin(angle - math.pi / 6))
    right = (end[0] - arrow_len * math.cos(angle + math.pi / 6), end[1] - arrow_len * math.sin(angle + math.pi / 6))
    draw.polygon([end, left, right], fill=color)

    mid_x = (start[0] + end[0]) / 2
    mid_y = (start[1] + end[1]) / 2
    label_w, label_h = text_size(draw, label, SMALL_FONT)
    draw.rounded_rectangle((mid_x - label_w / 2 - 18, mid_y - label_h / 2 - 8, mid_x + label_w / 2 + 18, mid_y + label_h / 2 + 8), radius=18, fill=COLORS["panel"], outline=color, width=2)
    draw.text((mid_x - label_w / 2, mid_y - label_h / 2 - 1), label, fill=color, font=SMALL_FONT)


def draw_notes_list(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], title: str, items: Iterable[str]) -> None:
    panel(draw, box, title=title, fill=COLORS["panel"])
    y = box[1] + 74
    for item in items:
        wrapped = wrap_text(draw, item, BODY_FONT, box[2] - box[0] - 80)
        draw.ellipse((box[0] + 28, y + 10, box[0] + 42, y + 24), fill=COLORS["primary"])
        draw.multiline_text((box[0] + 60, y), wrapped, fill=COLORS["muted"], font=BODY_FONT, spacing=6)
        y += text_size(draw, wrapped, BODY_FONT)[1] + 22


def create_page() -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGBA", PAGE_SIZE, COLORS["bg"])
    draw = ImageDraw.Draw(image)
    return image, draw


def save_preview(image: Image.Image, output: Path, max_width: int = 1800) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    preview = image.convert("RGB")
    if preview.width > max_width:
        ratio = max_width / preview.width
        preview = preview.resize((int(preview.width * ratio), int(preview.height * ratio)), Image.Resampling.LANCZOS)
    preview.save(output, format="PNG", optimize=True)


def use_case_ellipse(draw: ImageDraw.ImageDraw, center: tuple[int, int], size: tuple[int, int], text: str, fill: str) -> None:
    x, y = center
    w, h = size
    draw.ellipse((x - w // 2, y - h // 2, x + w // 2, y + h // 2), fill=fill, outline=COLORS["border"], width=3)
    wrapped = wrap_text(draw, text, BODY_FONT, w - 40)
    tw, th = text_size(draw, wrapped, BODY_FONT)
    draw.multiline_text((x - tw / 2, y - th / 2), wrapped, fill=COLORS["ink"], font=BODY_FONT, align="center", spacing=8)


def draw_actor(draw: ImageDraw.ImageDraw, center_x: int, center_y: int, label: str, subtitle: str = "") -> None:
    head_r = 34
    draw.ellipse((center_x - head_r, center_y - 120, center_x + head_r, center_y - 52), outline=COLORS["ink"], width=6)
    draw.line((center_x, center_y - 52, center_x, center_y + 45), fill=COLORS["ink"], width=6)
    draw.line((center_x - 58, center_y - 4, center_x + 58, center_y - 4), fill=COLORS["ink"], width=6)
    draw.line((center_x, center_y + 45, center_x - 50, center_y + 110), fill=COLORS["ink"], width=6)
    draw.line((center_x, center_y + 45, center_x + 50, center_y + 110), fill=COLORS["ink"], width=6)
    label_w, _ = text_size(draw, label, H2_FONT)
    draw.text((center_x - label_w / 2, center_y + 132), label, fill=COLORS["ink"], font=H2_FONT)
    if subtitle:
        sub = wrap_text(draw, subtitle, SMALL_FONT, 250)
        sw, sh = text_size(draw, sub, SMALL_FONT)
        draw.multiline_text((center_x - sw / 2, center_y + 174), sub, fill=COLORS["muted"], font=SMALL_FONT, align="center", spacing=4)


def connect_actor(draw: ImageDraw.ImageDraw, actor_point: tuple[int, int], use_case_center: tuple[int, int], color: str = COLORS["muted"]) -> None:
    draw.line((actor_point, use_case_center), fill=color, width=4)


def generate_architecture_pdf() -> None:
    pages: list[Image.Image] = []

    # Page 1: system context
    image, draw = create_page()
    draw_header(draw, "System Architecture", "WSU Inter-Office Communication System")

    admin_box = (220, 420, 880, 760)
    desktop_box = (220, 960, 880, 1360)
    backend_box = (1160, 620, 2380, 1140)
    db_box = (2640, 420, 3280, 760)
    files_box = (2540, 980, 3180, 1260)
    smtp_box = (2540, 1380, 3180, 1660)

    draw_box_with_text(draw, admin_box, "Admin Web Portal", "Browser-based interface for Admin users. Handles user management, announcements, chat, traffic logs, and admin profile updates.", COLORS["soft_blue"])
    draw_box_with_text(draw, desktop_box, "JavaFX Desktop Client", "Desktop application for Dept Head and Staff. Covers dashboard, tasks, announcements, chat, profile management, and password updates.", COLORS["soft_teal"])
    draw_box_with_text(draw, backend_box, "Apache Tomcat + backend-web", "JSP pages act as both web views and JSON endpoints. Core features include authentication, tasks, announcements, messaging, profile updates, and password reset processing.", COLORS["panel"])
    draw_box_with_text(draw, db_box, "MySQL / MariaDB", "Primary database: inter_office_db. Stores users, chats, tasks, announcements, task replies, and password reset tokens.", COLORS["soft_gold"])
    draw_box_with_text(draw, files_box, "File Storage", "Uploads are stored under backend assets for chat attachments, announcement files, task files, and profile images.", COLORS["soft_blue"])
    draw_box_with_text(draw, smtp_box, "Gmail SMTP", "Used by the password reset flow to send a one-time reset link to the user’s personal email address.", COLORS["soft_red"])

    draw_arrow(draw, (880, 590), (1160, 760), "HTML / JSP")
    draw_arrow(draw, (880, 1140), (1160, 980), "JSON / HTTP")
    draw_arrow(draw, (2380, 760), (2640, 590), "JDBC")
    draw_arrow(draw, (2380, 1050), (2540, 1105), "Read / Write files")
    draw_arrow(draw, (2380, 1090), (2540, 1520), "Reset email")

    draw_notes_list(
        draw,
        (220, 1740, 3280, 2260),
        "Architecture Notes",
        [
            "Role model: Admin uses the web portal only, while Dept Head and Staff use the desktop client.",
            "Desktop and web clients both depend on the same backend-web application deployed under http://localhost:8080/backend-web.",
            "The backend uses direct JDBC from JSPs. This is functional, but tightly couples SQL, transport, and page logic.",
            "Passwords are upgraded to bcrypt on successful login, and reset links are issued through the backend to personal email addresses.",
        ],
    )
    draw_footer(draw, "Page 1 of 2")
    page_one = image.convert("RGB")
    pages.append(page_one)

    # Page 2: request and module flow
    image, draw = create_page()
    draw_header(draw, "Architecture Flow View", "Request paths, modules, and runtime dependencies")

    draw_box_with_text(draw, (210, 380, 950, 760), "1. Authentication", "Desktop LoginController and admin login pages both reach backend auth endpoints. Successful login creates an HTTP session and returns role-linked data.", COLORS["soft_blue"])
    draw_box_with_text(draw, (1020, 380, 1770, 760), "2. Core Services", "Task, announcement, chat, profile, and password-reset JSP endpoints act as the application service layer currently exposed over HTTP.", COLORS["soft_teal"])
    draw_box_with_text(draw, (1840, 380, 2590, 760), "3. Persistence", "Each service endpoint talks to MySQL using direct JDBC with repeated connection strings and SQL statements.", COLORS["soft_gold"])
    draw_box_with_text(draw, (2660, 380, 3290, 760), "4. Output", "Responses are either rendered HTML pages for the web portal or JSON payloads for the desktop client.", COLORS["soft_red"])

    draw_arrow(draw, (950, 570), (1020, 570), "Calls")
    draw_arrow(draw, (1770, 570), (1840, 570), "SQL")
    draw_arrow(draw, (2590, 570), (2660, 570), "Data")

    panel(draw, (210, 930, 1640, 2200), title="Desktop-side Modules", fill=COLORS["panel"])
    desktop_items = [
        "MainApp -> Login.fxml / Dashboard.fxml",
        "Controllers: LoginController, DashboardController, ChatController, Task* controllers, ProfileController",
        "Transport: HttpConnector + multipart upload helpers",
        "State: UserSession, model classes, profile image utilities",
        "Navigation: dashboard overview, tasks page, announcements page, profile view, office chat",
    ]
    y = 1025
    for item in desktop_items:
        wrapped = wrap_text(draw, item, BODY_FONT, 1320)
        draw.rounded_rectangle((260, y, 1590, y + 120), radius=24, fill=COLORS["soft_blue"], outline=COLORS["border"], width=2)
        draw.multiline_text((290, y + 24), wrapped, fill=COLORS["ink"], font=BODY_FONT, spacing=6)
        y += 145

    panel(draw, (1870, 930, 3290, 2200), title="Backend-side Modules", fill=COLORS["panel"])
    backend_items = [
        "Public and admin web pages under admin/ plus index.jsp",
        "JSON-style APIs under api/ including auth.jsp, tasks.jsp, announcements.jsp, get_messages.jsp, get_users.jsp",
        "Shared auth/profile helpers such as auth_check.jsp and account_helpers.jspf",
        "Upload storage under assets/uploads and assets/img",
        "Runtime deployment under Tomcat webapps/backend-web",
    ]
    y = 1025
    for item in backend_items:
        wrapped = wrap_text(draw, item, BODY_FONT, 1320)
        draw.rounded_rectangle((1920, y, 3240, y + 120), radius=24, fill=COLORS["soft_teal"], outline=COLORS["border"], width=2)
        draw.multiline_text((1950, y + 24), wrapped, fill=COLORS["ink"], font=BODY_FONT, spacing=6)
        y += 145

    draw_footer(draw, "Page 2 of 2")
    page_two = image.convert("RGB")
    pages.append(page_two)

    output = DOCS / "System_Architecture.pdf"
    pages[0].save(output, save_all=True, append_images=pages[1:], resolution=300.0)
    save_preview(page_one, SCREENSHOTS / "system-architecture-overview.png")
    save_preview(page_two, SCREENSHOTS / "system-architecture-flow.png")


def generate_use_case_pdf() -> None:
    pages: list[Image.Image] = []

    # Page 1: overview
    image, draw = create_page()
    draw_header(draw, "Use Case Diagrams", "Academic overview of major actor interactions")

    system_box = (720, 300, 2900, 2120)
    draw.rounded_rectangle(system_box, radius=34, fill=COLORS["panel"], outline=COLORS["primary"], width=4)
    draw.text((system_box[0] + 26, system_box[1] + 18), "WSU Inter-Office Communication System", fill=COLORS["primary"], font=H1_FONT)

    draw_actor(draw, 350, 760, "Admin", "Web portal only")
    draw_actor(draw, 350, 1410, "Dept Head", "Desktop client")
    draw_actor(draw, 3240, 1080, "Staff", "Desktop client")

    overview_cases = [
        ((1180, 600), (460, 136), "Manage users", COLORS["soft_blue"]),
        ((1770, 600), (560, 136), "Manage announcements", COLORS["soft_blue"]),
        ((2380, 600), (430, 136), "View traffic logs", COLORS["soft_blue"]),
        ((1180, 1010), (520, 136), "Create and edit tasks", COLORS["soft_teal"]),
        ((1770, 1010), (590, 136), "Review and close tasks", COLORS["soft_teal"]),
        ((2380, 1010), (470, 136), "Post announcements", COLORS["soft_teal"]),
        ((1180, 1420), (470, 136), "View assigned tasks", COLORS["soft_gold"]),
        ((1770, 1420), (620, 136), "Submit task completion", COLORS["soft_gold"]),
        ((2380, 1420), (500, 136), "Read announcements", COLORS["soft_gold"]),
        ((1450, 1830), (420, 136), "Office chat", COLORS["soft_red"]),
        ((2190, 1830), (640, 136), "Update profile and password", COLORS["soft_red"]),
    ]
    for center, size, text, fill in overview_cases:
        use_case_ellipse(draw, center, size, text, fill)

    # connections
    for target in [(1180, 600), (1770, 600), (2380, 600), (1450, 1830), (2190, 1830)]:
        connect_actor(draw, (420, 760), target)
    for target in [(1180, 1010), (1770, 1010), (2380, 1010), (1450, 1830), (2190, 1830)]:
        connect_actor(draw, (420, 1410), target)
    for target in [(1180, 1420), (1770, 1420), (2380, 1420), (1450, 1830), (2190, 1830)]:
        connect_actor(draw, (3170, 1080), target)

    draw_footer(draw, "Page 1 of 4")
    overview_page = image.convert("RGB")
    pages.append(overview_page)

    def actor_page(title: str, actor_label: str, subtitle: str, use_cases: list[str], fill: str, page_label: str) -> Image.Image:
        image, draw = create_page()
        draw_header(draw, title, subtitle)
        draw_actor(draw, 430, 1130, actor_label, subtitle)

        boundary = (860, 320, 3230, 2200)
        draw.rounded_rectangle(boundary, radius=34, fill=COLORS["panel"], outline=COLORS["primary"], width=4)
        draw.text((boundary[0] + 24, boundary[1] + 18), "System Boundary", fill=COLORS["primary"], font=H1_FONT)

        left_x = 1600
        right_x = 2540
        middle_x = (left_x + right_x) // 2
        start_y = 650
        row_gap = 275

        row_index = 0
        for idx in range(0, len(use_cases), 2):
            pair = use_cases[idx : idx + 2]
            y = start_y + row_index * row_gap
            centers: list[tuple[int, int]]
            if len(pair) == 1:
                centers = [(middle_x, y)]
            else:
                centers = [(left_x, y), (right_x, y)]

            for case_text, center in zip(pair, centers):
                size = (760, 160)
                if len(case_text) > 26:
                    size = (820, 170)
                use_case_ellipse(draw, center, size, case_text, fill)
                connect_actor(draw, (500, 1130), center)

            row_index += 1

        draw_footer(draw, page_label)
        return image.convert("RGB")

    admin_page = actor_page(
        "Admin Use Cases",
        "Admin",
        "Administrative interactions through the web portal",
        [
            "Sign in to admin portal",
            "Manage users",
            "Create / edit announcements",
            "Use admin chat",
            "View traffic logs",
            "Update admin profile",
        ],
        COLORS["soft_blue"],
        "Page 2 of 4",
    )
    pages.append(admin_page)

    dept_head_page = actor_page(
        "Dept Head Use Cases",
        "Dept Head",
        "Department-level interactions through the desktop client",
        [
            "Sign in to desktop",
            "View dashboard overview",
            "Create tasks",
            "Edit / delete tasks",
            "Review staff submissions",
            "Acknowledge & close tasks",
            "Post department announcements",
            "Direct and department chat",
            "Update profile & password",
        ],
        COLORS["soft_teal"],
        "Page 3 of 4",
    )
    pages.append(dept_head_page)

    staff_page = actor_page(
        "Staff Use Cases",
        "Staff",
        "Operational staff interactions through the desktop client",
        [
            "Sign in to desktop",
            "View assigned tasks",
            "Submit task reply",
            "Upload completion file",
            "Read department announcements",
            "Direct and department chat",
            "Update profile & password",
        ],
        COLORS["soft_gold"],
        "Page 4 of 4",
    )
    pages.append(staff_page)

    output = DOCS / "Use_Case_Diagrams.pdf"
    pages[0].save(output, save_all=True, append_images=pages[1:], resolution=300.0)
    save_preview(overview_page, SCREENSHOTS / "use-case-overview.png")
    save_preview(admin_page, SCREENSHOTS / "use-case-admin.png")
    save_preview(dept_head_page, SCREENSHOTS / "use-case-dept-head.png")
    save_preview(staff_page, SCREENSHOTS / "use-case-staff.png")


def main() -> None:
    generate_architecture_pdf()
    generate_use_case_pdf()
    print("Generated:")
    print(DOCS / "System_Architecture.pdf")
    print(DOCS / "Use_Case_Diagrams.pdf")


if __name__ == "__main__":
    main()

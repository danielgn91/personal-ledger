from nicegui import ui
from app.application.state import application
from app.ui.utils import t
from pathlib import Path

@ui.page("/")
def home():

    with ui.column().classes(
        'w-full h-screen items-center justify-center gap-6'
    ):

        ui.label(t('title')).classes(
            'text-4xl font-bold'
        )

        ui.button(
            t('new_ledger'),
            icon='add',
            on_click=new_ledger,
        ).classes(
            'w-64'
        )

        ui.button(
            t('open_ledger'),
            icon='folder_open',
            on_click=open_ledger,
        ).classes(
            'w-64'
        )


def new_ledger():
    with ui.dialog() as dialog, ui.card():
        ui.label(t("new_ledger"))

        name = ui.input(t("name"))

        def create():
            application.create_ledger(name.value)

            dialog.close()

            ui.navigate.to("/transactions")

        ui.button(
            t("create"),
            on_click=create
        )

    dialog.open()

def open_ledger():
    with ui.dialog() as dialog, ui.card():
        ui.label(t("open_ledger"))

        def handle_upload(event):
            path = Path(event.file.name)

            application.open_ledger(path)

            dialog.close()
            ui.navigate.to("/transactions")

        ui.upload(
            label=t("select_file"),
            on_upload=handle_upload,
            auto_upload=True,
        )

    dialog.open()
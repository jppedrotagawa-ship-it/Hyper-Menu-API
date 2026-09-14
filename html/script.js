window.addEventListener('message', function(event) {
    let data = event.data;
    
    if (data.type === "ui") {
        let container = document.getElementById("hyper-container");
        if (data.status) {
            container.style.display = "flex";
        } else {
            container.style.display = "none";
        }
    }
});

// Troca de Abas do Menu
document.querySelectorAll('.menu-list li').forEach(item => {
    item.addEventListener('click', function() {
        document.querySelectorAll('.menu-list li').forEach(el => el.classList.remove('active'));
        this.classList.add('active');

        let target = this.getAttribute('data-target');
        document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active'));
        
        let targetPane = document.getElementById(target);
        if (targetPane) {
            targetPane.classList.add('active');
        }
    });
});

// Fechar com a tecla ESC (comunicação futura com o Client Lua)
document.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/closeMenu`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

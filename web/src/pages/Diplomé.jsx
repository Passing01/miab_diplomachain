import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import './Diplomé.css'

function Diplomé() {
  const navigate = useNavigate()
  const [onglet, setOnglet] = useState('diplome')

  const consultations = [
    { date: '23/04/2026 09:32', organisme: 'ONEA DRH', type: 'Scan QR', resultat: 'valide' },
    { date: '22/04/2026 09:32', organisme: 'SONABEL DRH', type: 'Recherche manuelle', resultat: 'valide' },
  ]

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="sidebar-logo">
          <span className="logo-diplo">Diplo</span><span className="logo-chain">Chain</span><span className="logo-bf"> BF</span>
        </div>
        <div className="sidebar-user">
          <div className="avatar">OJ</div>
          <div>
            <p className="user-name">OUEDRAOGO J.</p>
            <p className="user-role">Diplômé(e)</p>
          </div>
        </div>
        <nav className="sidebar-nav">
          <p className="nav-section">MON ESPACE</p>
          <a className={`nav-item ${onglet === 'diplome' ? 'active' : ''}`} onClick={() => setOnglet('diplome')}>🎓 Mon diplôme</a>
          <a className={`nav-item ${onglet === 'qr' ? 'active' : ''}`} onClick={() => setOnglet('qr')}>📱 Mon QR Code</a>
          <a className={`nav-item ${onglet === 'consultations' ? 'active' : ''}`} onClick={() => setOnglet('consultations')}>👁 Consultations reçues</a>
          <p className="nav-section">COMPTE</p>
          <a className={`nav-item ${onglet === 'profil' ? 'active' : ''}`} onClick={() => setOnglet('profil')}>👤 Mon profil</a>
          <a className={`nav-item ${onglet === 'notifications' ? 'active' : ''}`} onClick={() => setOnglet('notifications')}>🔔 Notifications</a>
          <a className="nav-item">🚪 Déconnexion</a>
        </nav>
        <div className="sidebar-switch">
          <button onClick={() => navigate('/universite')}>Espace Établissement</button>
          <button onClick={() => navigate('/verification')}>Espace Recruteur</button>
        </div>
      </aside>

      <main className="main">
        <div className="topbar">
          <h1>
            {onglet === 'diplome' && 'Mon Diplôme Numérique'}
            {onglet === 'qr' && 'Mon QR Code'}
            {onglet === 'consultations' && 'Consultations reçues'}
            {onglet === 'profil' && 'Mon Profil'}
            {onglet === 'notifications' && 'Notifications'}
          </h1>
          <div className="topbar-actions">
            <button className="btn-secondary">📤 Partager</button>
            <button className="btn-primary">⬇ Télécharger PDF</button>
          </div>
        </div>

        {onglet === 'diplome' && <>
          <div className="diplome-card">
            <div className="diplome-card-header">
              <p className="diplome-country">Burkina Faso — Diplôme Officiel</p>
              <h2 className="diplome-name">OUEDRAOGO Henry Joel</h2>
            </div>
            <div className="diplome-grid">
              <div className="diplome-field"><span className="field-label">Diplôme</span><span className="field-value">Licence 3 SIR</span></div>
              <div className="diplome-field"><span className="field-label">Mention</span><span className="field-value">Bien</span></div>
              <div className="diplome-field"><span className="field-label">Établissement</span><span className="field-value">Université Thomas SANKARA</span></div>
              <div className="diplome-field"><span className="field-label">Matricule</span><span className="field-value">UO2-2024-1187</span></div>
              <div className="diplome-field"><span className="field-label">Année</span><span className="field-value">2025-2026</span></div>
              <div className="diplome-field"><span className="field-label">Délivré le</span><span className="field-value">20 Avril 2026</span></div>
            </div>
          </div>
          <div className="card statut-card">
            <div className="statut-icon">✅</div>
            <div>
              <p className="statut-title">Diplôme Authentique et Actif</p>
              <p className="statut-desc">Votre diplôme est enregistré dans le système officiel DiploChain BF et peut être vérifié à tout moment par un recruteur.</p>
            </div>
          </div>
        </>}

        {onglet === 'qr' && <>
          <div className="card qr-card">
            <div className="qr-left">
              <div className="qr-box">
                <div className="qr-pattern">▦</div>
              </div>
            </div>
            <div className="qr-right">
              <h3>QR Code de Vérification Sécurisé</h3>
              <p>Présentez ce code à tout recruteur pour vérification instantanée de l'authenticité de votre diplôme.</p>
              <div className="qr-actions">
                <button className="btn-secondary">📋 Copier le lien</button>
                <button className="btn-primary">⬇ Télécharger QR</button>
              </div>
            </div>
          </div>
        </>}

        {onglet === 'consultations' && <>
          <div className="card">
            <div className="card-header">
              <h2>Historique des consultations</h2>
              <span className="badge-count">{consultations.length} consultations</span>
            </div>
            <p className="card-subtitle">Qui a consulté mon diplôme ?</p>
            <table className="table">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Organisme</th>
                  <th>Type</th>
                  <th>Résultat</th>
                </tr>
              </thead>
              <tbody>
                {consultations.map((c, i) => (
                  <tr key={i}>
                    <td>{c.date}</td>
                    <td>{c.organisme}</td>
                    <td>{c.type}</td>
                    <td><span className="badge badge-valide">✓ Valide</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>}

        {onglet === 'profil' && <>
          <div className="card">
            <div className="card-header">
              <h2>Informations personnelles</h2>
            </div>
            <div className="form-grid">
              <div className="form-group"><label>Nom complet</label><input defaultValue="OUEDRAOGO Henry Joel" /></div>
              <div className="form-group"><label>Matricule</label><input defaultValue="UO2-2024-1187" readOnly /></div>
              <div className="form-group"><label>Email</label><input defaultValue="h.ouedraogo@uts.bf" /></div>
              <div className="form-group"><label>Téléphone</label><input defaultValue="+226 70 00 00 00" /></div>
            </div>
            <div className="form-actions">
              <button className="btn-primary">Enregistrer</button>
            </div>
          </div>
        </>}

        {onglet === 'notifications' && <>
          <div className="card">
            <div className="card-header">
              <h2>Notifications</h2>
            </div>
            <div className="notif-item">
              <p className="notif-title">ONEA DRH a consulté votre diplôme</p>
              <p className="notif-date">23/04/2026 à 09:32</p>
            </div>
            <div className="notif-item">
              <p className="notif-title">SONABEL DRH a consulté votre diplôme</p>
              <p className="notif-date">22/04/2026 à 09:32</p>
            </div>
          </div>
        </>}

      </main>
    </div>
  )
}

export default Diplomé
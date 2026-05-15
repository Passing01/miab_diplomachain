import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import './Universite.css'

function Universite() {
  const navigate = useNavigate()
  const [form, setForm] = useState({
    nom: 'OUEDRAOGO Henry Joel',
    matricule: 'UO2-2024-1187',
    diplome: 'Licence 3 - SIR',
    annee: '2025-2026',
    mention: 'Bien',
    date: '20/04/2026'
  })

  const diplomes = [
    { matricule: 'UO2-2024-1186', nom: 'OUEDRAOGO Abdoul Rahim', diplome: 'L3 - SIR', date: '20/06/2026', statut: 'valide' },
    { matricule: 'UO2-2024-1185', nom: 'SAWADOGO Awa', diplome: 'M2 - Droit', date: '20/06/2026', statut: 'révoqué' },
    { matricule: 'UO2-2024-1184', nom: 'DAPELGO NOE', diplome: 'L3 - Gestion', date: '20/06/2026', statut: 'attente' },
  ]

  return (
    <div className="layout">

      {/* SIDEBAR */}
      <aside className="sidebar">
        <div className="sidebar-logo">
          <span className="logo-diplo">Diplo</span><span className="logo-chain">Chain</span><span className="logo-bf"> BF</span>
        </div>
        <div className="sidebar-user">
          <div className="avatar">UTS</div>
          <div>
            <p className="user-name">Université Thomas SANKARA</p>
            <p className="user-role">Administrateur</p>
          </div>
        </div>
        <nav className="sidebar-nav">
          <p className="nav-section">PRINCIPAL</p>
          <a className="nav-item active">📊 Tableau de bord</a>
          <a className="nav-item">➕ Nouveau diplôme</a>
          <a className="nav-item">📋 Registre diplômés</a>
          <a className="nav-item">🔍 Rechercher</a>
          <p className="nav-section">GESTION</p>
          <a className="nav-item">⚠️ Diplômes révoqués</a>
          <a className="nav-item">📈 Statistiques</a>
          <a className="nav-item">⚙️ Paramètres</a>
        </nav>
        <div className="sidebar-switch">
          <button onClick={() => navigate('/diplome')}>Espace Diplômé</button>
          <button onClick={() => navigate('/verification')}>Espace Recruteur</button>
        </div>
      </aside>

      {/* MAIN */}
      <main className="main">
        <div className="topbar">
          <h1>Tableau de bord</h1>
          <div className="topbar-actions">
            <button className="btn-secondary">📥 Importer CSV</button>
            <button className="btn-primary">➕ Enregistrer un diplôme</button>
          </div>
        </div>

        {/* STATS */}
        <div className="stats-grid">
          <div className="stat-card">
            <p className="stat-label">Total Diplômes</p>
            <p className="stat-value">3 842</p>
            <p className="stat-sub green">↑ +127 ce mois</p>
          </div>
          <div className="stat-card">
            <p className="stat-label">Vérifications</p>
            <p className="stat-value">1 209</p>
            <p className="stat-sub green">↑ +89 cette semaine</p>
          </div>
          <div className="stat-card">
            <p className="stat-label">Révoqués</p>
            <p className="stat-value red">14</p>
            <p className="stat-sub red">↑ +2 ce mois</p>
          </div>
          <div className="stat-card">
            <p className="stat-label">En attente</p>
            <p className="stat-value amber">6</p>
            <p className="stat-sub">À valider</p>
          </div>
        </div>

        {/* FORMULAIRE */}
        <div className="card">
          <div className="card-header">
            <h2>Nouveau diplôme</h2>
            <span className="badge-draft">⏳ Brouillon</span>
          </div>
          <div className="form-grid">
            <div className="form-group">
              <label>Nom du diplômé</label>
              <input value={form.nom} onChange={e => setForm({...form, nom: e.target.value})} />
            </div>
            <div className="form-group">
              <label>Matricule</label>
              <input value={form.matricule} onChange={e => setForm({...form, matricule: e.target.value})} />
            </div>
            <div className="form-group">
              <label>Diplôme obtenu</label>
              <select value={form.diplome} onChange={e => setForm({...form, diplome: e.target.value})}>
                <option>Licence 3 - SIR</option>
                <option>Master 2 - Informatique</option>
                <option>Licence 3 - Gestion</option>
                <option>Master 2 - Droit</option>
              </select>
            </div>
            <div className="form-group">
              <label>Mention</label>
              <select value={form.mention} onChange={e => setForm({...form, mention: e.target.value})}>
                <option>Très bien</option>
                <option>Bien</option>
                <option>Assez bien</option>
                <option>Passable</option>
              </select>
            </div>
            <div className="form-group">
              <label>Année universitaire</label>
              <select value={form.annee} onChange={e => setForm({...form, annee: e.target.value})}>
                <option>2025-2026</option>
                <option>2024-2025</option>
              </select>
            </div>
            <div className="form-group">
              <label>Date de délivrance</label>
              <input type="date" />
            </div>
          </div>
          <div className="form-actions">
            <button className="btn-cancel">Annuler</button>
            <button className="btn-primary">✅ Enregistrer & Générer QR</button>
          </div>
        </div>

        {/* TABLEAU */}
        <div className="card">
          <div className="card-header">
            <h2>Diplômes récemment enregistrés</h2>
            <span className="registre-label">Registre — 3 derniers</span>
            <button className="btn-link">Voir tout →</button>
          </div>
          <table className="table">
            <thead>
              <tr>
                <th>Matricule</th>
                <th>Nom complet</th>
                <th>Diplôme</th>
                <th>Date</th>
                <th>Statut</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {diplomes.map((d, i) => (
                <tr key={i}>
                  <td className="mono">{d.matricule}</td>
                  <td>{d.nom}</td>
                  <td>{d.diplome}</td>
                  <td>{d.date}</td>
                  <td>
                    <span className={`badge badge-${d.statut}`}>
                      {d.statut === 'valide' ? '✓ Valide' : d.statut === 'révoqué' ? '✗ Révoqué' : '⏳ En attente'}
                    </span>
                  </td>
                  <td className="actions">
                    {d.statut === 'valide' && <button className="btn-sm">QR</button>}
                    {d.statut === 'révoqué' && <button className="btn-sm">Détails</button>}
                    {d.statut === 'attente' && <button className="btn-sm green">Valider</button>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

      </main>
    </div>
  )
}

export default Universite
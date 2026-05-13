import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Universite from './pages/Universite'
import Diplomé from './pages/Diplomé'
import Verification from './pages/Verification'
import './App.css'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/universite" />} />
        <Route path="/universite" element={<Universite />} />
        <Route path="/diplome" element={<Diplomé />} />
        <Route path="/verification" element={<Verification />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
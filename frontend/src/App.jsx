import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import Home from './pages/Home'
import Items from './pages/Items'
import About from './pages/About'
import Dashboard from './pages/Dashboard'
import UserRegistration from './pages/UserRegistration'
import RegistrationSuccess from './pages/RegistrationSuccess'
import './App.css'

function App() {
  return (
    <Router>
      <Routes>
        {/* Rutas con Layout */}
        <Route path="/" element={<Layout><Home /></Layout>} />
        <Route path="/dashboard" element={<Layout><Dashboard /></Layout>} />
        <Route path="/items" element={<Layout><Items /></Layout>} />
        <Route path="/about" element={<Layout><About /></Layout>} />
        
        {/* Rutas sin Layout (fullscreen) */}
        <Route path="/registro" element={<UserRegistration />} />
        <Route path="/registro-exitoso" element={<RegistrationSuccess />} />
      </Routes>
    </Router>
  )
}

export default App


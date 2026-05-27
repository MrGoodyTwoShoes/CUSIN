'use client'

import { useState } from 'react'
import { Shield, Map, Users, AlertTriangle } from 'lucide-react'

export default function Home() {
  const [activeTab, setActiveTab] = useState('dashboard')

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-3">
              <Shield className="h-8 w-8 text-blue-600" />
              <h1 className="text-2xl font-bold text-gray-900">CUSIN Admin</h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-600">Admin User</span>
              <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <nav className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            <button
              onClick={() => setActiveTab('dashboard')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'dashboard'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Dashboard
            </button>
            <button
              onClick={() => setActiveTab('moderation')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'moderation'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Moderation Queue
            </button>
            <button
              onClick={() => setActiveTab('incidents')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'incidents'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Incidents
            </button>
            <button
              onClick={() => setActiveTab('users')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'users'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Users
            </button>
          </div>
        </div>
      </nav>

      {/* Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'dashboard' && <DashboardContent />}
        {activeTab === 'moderation' && <ModerationContent />}
        {activeTab === 'incidents' && <IncidentsContent />}
        {activeTab === 'users' && <UsersContent />}
      </main>
    </div>
  )
}

function DashboardContent() {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Dashboard</h2>
      
      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <AlertTriangle className="h-8 w-8 text-orange-500" />
            <div className="ml-4">
              <p className="text-sm text-gray-500">Pending Reviews</p>
              <p className="text-2xl font-bold text-gray-900">24</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <Map className="h-8 w-8 text-blue-500" />
            <div className="ml-4">
              <p className="text-sm text-gray-500">Total Incidents</p>
              <p className="text-2xl font-bold text-gray-900">1,234</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <Users className="h-8 w-8 text-green-500" />
            <div className="ml-4">
              <p className="text-sm text-gray-500">Active Users</p>
              <p className="text-2xl font-bold text-gray-900">5,678</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center">
            <Shield className="h-8 w-8 text-purple-500" />
            <div className="ml-4">
              <p className="text-sm text-gray-500">Avg Trust Score</p>
              <p className="text-2xl font-bold text-gray-900">72.5</p>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b">
          <h3 className="text-lg font-medium text-gray-900">Recent Activity</h3>
        </div>
        <div className="px-6 py-4">
          <p className="text-gray-500">Recent activity will be displayed here.</p>
        </div>
      </div>
    </div>
  )
}

function ModerationContent() {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Moderation Queue</h2>
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b">
          <div className="flex justify-between items-center">
            <h3 className="text-lg font-medium text-gray-900">Pending Reviews</h3>
            <div className="flex space-x-2">
              <select className="border rounded-lg px-3 py-2 text-sm">
                <option>All Priorities</option>
                <option>Critical</option>
                <option>High</option>
                <option>Normal</option>
                <option>Low</option>
              </select>
            </div>
          </div>
        </div>
        <div className="px-6 py-4">
          <p className="text-gray-500">Moderation queue items will be displayed here.</p>
        </div>
      </div>
    </div>
  )
}

function IncidentsContent() {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Incidents</h2>
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b">
          <h3 className="text-lg font-medium text-gray-900">All Incidents</h3>
        </div>
        <div className="px-6 py-4">
          <p className="text-gray-500">Incident list will be displayed here.</p>
        </div>
      </div>
    </div>
  )
}

function UsersContent() {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Users</h2>
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b">
          <h3 className="text-lg font-medium text-gray-900">User Management</h3>
        </div>
        <div className="px-6 py-4">
          <p className="text-gray-500">User list will be displayed here.</p>
        </div>
      </div>
    </div>
  )
}

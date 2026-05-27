// Helper utilities for CUSIN backend

class Helpers {
  // Generate random string
  static generateRandomString(length = 32) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  // Format date for display
  static formatDate(date, format = 'ISO') {
    const d = new Date(date);
    
    if (isNaN(d.getTime())) {
      return null;
    }
    
    switch (format) {
      case 'ISO':
        return d.toISOString();
      case 'readable':
        return d.toLocaleDateString('en-KE', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        });
      case 'time':
        return d.toLocaleTimeString('en-KE');
      case 'date':
        return d.toLocaleDateString('en-KE');
      default:
        return d.toISOString();
    }
  }

  // Calculate distance between two points (Haversine formula)
  static calculateDistance(point1, point2) {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(point2.lat - point1.lat);
    const dLon = this.toRad(point2.lng - point1.lng);
    
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(point1.lat)) *
        Math.cos(this.toRad(point2.lat)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  static toRad(degrees) {
    return degrees * (Math.PI / 180);
  }

  // Convert meters to kilometers
  static metersToKm(meters) {
    return meters / 1000;
  }

  // Convert kilometers to meters
  static kmToMeters(km) {
    return km * 1000;
  }

  // Truncate text
  static truncateText(text, maxLength = 100, suffix = '...') {
    if (!text || text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  // Deep clone object
  static deepClone(obj) {
    return JSON.parse(JSON.stringify(obj));
  }

  // Sleep function for async operations
  static sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Retry function with exponential backoff
  static async retry(fn, maxRetries = 3, delay = 1000) {
    for (let i = 0; i < maxRetries; i++) {
      try {
        return await fn();
      } catch (error) {
        if (i === maxRetries - 1) {
          throw error;
        }
        await this.sleep(delay * Math.pow(2, i));
      }
    }
  }

  // Paginate array
  static paginate(array, page = 1, perPage = 10) {
    const offset = (page - 1) * perPage;
    const paginated = array.slice(offset, offset + perPage);
    
    return {
      data: paginated,
      pagination: {
        page,
        perPage,
        total: array.length,
        totalPages: Math.ceil(array.length / perPage),
        hasNext: offset + perPage < array.length,
        hasPrev: page > 1
      }
    };
  }

  // Group array by key
  static groupBy(array, key) {
    return array.reduce((result, item) => {
      const groupKey = item[key];
      if (!result[groupKey]) {
        result[groupKey] = [];
      }
      result[groupKey].push(item);
      return result;
    }, {});
  }

  // Sort array by key
  static sortBy(array, key, order = 'asc') {
    return array.sort((a, b) => {
      if (order === 'asc') {
        return a[key] > b[key] ? 1 : -1;
      } else {
        return a[key] < b[key] ? 1 : -1;
      }
    });
  }

  // Calculate percentage
  static calculatePercentage(value, total) {
    if (total === 0) return 0;
    return (value / total) * 100;
  }

  // Round to decimal places
  static round(value, decimals = 2) {
    return Math.round(value * Math.pow(10, decimals)) / Math.pow(10, decimals);
  }

  // Format number with commas
  static formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  // Get time ago string
  static timeAgo(date) {
    const seconds = Math.floor((new Date() - new Date(date)) / 1000);
    
    const intervals = {
      year: 31536000,
      month: 2592000,
      week: 604800,
      day: 86400,
      hour: 3600,
      minute: 60
    };
    
    for (const [unit, secondsInUnit] of Object.entries(intervals)) {
      const interval = Math.floor(seconds / secondsInUnit);
      if (interval >= 1) {
        return `${interval} ${unit}${interval > 1 ? 's' : ''} ago`;
      }
    }
    
    return 'just now';
  }

  // Validate and sanitize query parameters
  static sanitizeQueryParams(params, allowedParams) {
    const sanitized = {};
    
    for (const param of allowedParams) {
      if (params[param] !== undefined) {
        sanitized[param] = params[param];
      }
    }
    
    return sanitized;
  }

  // Extract IP address from request
  static extractIP(req) {
    return req.ip || 
           req.connection?.remoteAddress || 
           req.socket?.remoteAddress ||
           (req.connection?.socket ? req.connection.socket.remoteAddress : null) ||
           req.headers['x-forwarded-for']?.split(',')[0].trim() ||
           req.headers['x-real-ip'] ||
           '0.0.0.0';
  }

  // Extract user agent from request
  static extractUserAgent(req) {
    return req.headers['user-agent'] || 'Unknown';
  }

  // Generate pagination metadata
  static generatePaginationMeta(total, page, perPage) {
    const totalPages = Math.ceil(total / perPage);
    
    return {
      total,
      page: parseInt(page),
      perPage: parseInt(perPage),
      totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1
    };
  }

  // Safe JSON parse
  static safeJSONParse(json, defaultValue = null) {
    try {
      return JSON.parse(json);
    } catch (error) {
      return defaultValue;
    }
  }

  // Mask sensitive data
  static maskSensitiveData(data, fieldsToMask = ['password', 'phone', 'email']) {
    const masked = { ...data };
    
    for (const field of fieldsToMask) {
      if (masked[field]) {
        const value = masked[field].toString();
        if (value.length > 4) {
          masked[field] = value.substring(0, 2) + '*'.repeat(value.length - 4) + value.substring(value.length - 2);
        } else {
          masked[field] = '*'.repeat(value.length);
        }
      }
    }
    
    return masked;
  }

  // Calculate age from date of birth
  static calculateAge(dateOfBirth) {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  }

  // Check if date is within range
  static isDateInRange(date, startDate, endDate) {
    const d = new Date(date);
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    return d >= start && d <= end;
  }

  // Get date range for common periods
  static getDateRange(period) {
    const now = new Date();
    const start = new Date();
    
    switch (period) {
      case 'today':
        start.setHours(0, 0, 0, 0);
        return { start, end: now };
      case 'yesterday':
        start.setDate(start.getDate() - 1);
        start.setHours(0, 0, 0, 0);
        const endYesterday = new Date(start);
        endYesterday.setHours(23, 59, 59, 999);
        return { start, end: endYesterday };
      case 'week':
        start.setDate(start.getDate() - 7);
        return { start, end: now };
      case 'month':
        start.setMonth(start.getMonth() - 1);
        return { start, end: now };
      case 'year':
        start.setFullYear(start.getFullYear() - 1);
        return { start, end: now };
      default:
        return { start, end: now };
    }
  }
}

module.exports = Helpers;

---
title: "Projects"
layout: single
permalink: /projects/
author_profile: false
header:
    overlay_image: /assets/logos/background.png
    overlay_filter: 0.3
---

<div class="projects-container">
{% assign sorted_projects = site.projects | sort: 'date' | reverse %}
{% for project in sorted_projects %}
    <div class="project-item">
        {% if project.image %}
        <div class="project-image">
            <img src="{{ project.image }}" alt="{{ project.title }} 이미지"
                 style="width:{{ project.image_width | default: '100%' }}; height:100%; object-fit:contain; display:block; margin:0 auto;"
                 onerror="this.parentElement.style.display='none'">
        </div>
        {% endif %}
        <h2>{{ project.title }}</h2>
        <div class="project-content">
            <p class="project-summary">{{ project.summary | newline_to_br }}</p>
            {% if project.tags %}
            <div class="project-tags">
                {% for tag in project.tags %}
                <span class="tag">{{ tag }}</span>
                {% endfor %}
            </div>
            {% endif %}
            <div class="project-links">
                <div class="project-links-left">
                    {% if project.github %}
                    <a href="{{ project.github }}" class="btn btn--primary" target="_blank">GitHub</a>
                    {% endif %}
                    {% if project.demo %}
                    <a href="{{ project.demo }}" class="btn btn--primary" target="_blank">Demo</a>
                    {% endif %}
                </div>
                <div class="project-links-right">
                    <a href="{{ project.url }}" class="btn btn--link">View Project →</a>
                </div>
            </div>
        </div>
    </div>
{% endfor %}
</div>

<style>
.projects-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.project-item {
    margin-bottom: 40px;
    padding: 20px;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    background-color: #fff;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.project-image {
    width: 100%;
    height: 330px;
    margin-bottom: 20px;
    border-radius: 4px;
    overflow: hidden;
}

.project-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.3s ease;
}

.project-image img:hover {
    transform: scale(1.05);
}

.project-item h2 {
    color: #2a2a2a;
    margin-bottom: 15px;
}

.project-content {
    color: #4a4a4a;
}

.project-summary {
    margin-bottom: 20px;
    line-height: 1.6;
}

.project-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 20px;
}

.tag {
    display: inline-flex;
    align-items: center;
    padding: 4px 16px 4px 25px;
    background-color: #f0f0f0;
    color: #666;
    border-radius: 16px;
    font-size: 0.9em;
    transition: all 0.3s ease;
    margin-right: 0;
}

.tag:hover {
    background-color: #e0e0e0;
    transform: translateY(-1px);
}

.project-links {
    margin-top: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.project-links-left {
    display: flex;
    gap: 10px;
}

.project-links-right {
    margin-left: auto;
}

.btn {
    display: inline-block;
    padding: 8px 16px;
    border-radius: 4px;
    text-decoration: none;
    transition: all 0.3s ease;
}

.btn--primary {
    background-color: #2a2a2a;
    color: #fff;
}

.btn--primary:hover {
    background-color: #404040;
    transform: translateY(-2px);
}

.btn--link {
    color: #0066cc;
    padding: 0;
    font-weight: 500;
}

.btn--link:hover {
    color: #0052a3;
    transform: translateX(4px);
}
</style> 
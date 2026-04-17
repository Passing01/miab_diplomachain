from django.shortcuts import render


def index(request):
    return render(request, 'landing_page/index.html')


def probleme(request):
    return render(request, 'landing_page/probleme.html')


def solution(request):
    return render(request, 'landing_page/solution.html')


def comment(request):
    return render(request, 'landing_page/comment.html')


def technologie(request):
    return render(request, 'landing_page/technologie.html')

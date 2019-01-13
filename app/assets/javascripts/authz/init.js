class Page {
    controller() {
        return $('meta[name=page-specific-javascript]').attr('controller');
    }
    action() {
        return $('meta[name=page-specific-javascript]').attr('action');
    }
    module() {
        return $('meta[name=page-specific-javascript]').attr('module');
    }
}

this.page = new Page;

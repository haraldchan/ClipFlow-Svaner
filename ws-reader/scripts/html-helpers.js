function html(strings, ...values) {
    let result = ''

    for (let i = 0; i < values.length; i++) {
        result += strings[i]
        let value = values[i]

        if (
            value &&
            Symbol.iterator in Object(value) &&
            typeof value !== 'string'
        ) {
            result += [...value].join('')
        } else {
            result += value ?? ''
        }
    }

    return result + strings.at(-1)
}

function each(iterable, render) {
    let html = ''

    for (const item of iterable)
        html += render(item)

    return html
}

function debounce(fn, delay = 300) {
    let timer

    return (...args) => {
        clearTimeout(timer)

        timer = setTimeout(() => {
            fn(...args)
        }, delay)
    }
}
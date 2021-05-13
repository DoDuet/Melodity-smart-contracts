export default function helper() {
    const convertToNumber = (raw) => {
        return +convertToDisplayable(raw)
    }

    const convertToDisplayable = (raw) => {
        return raw.toString()
    }

    const prettyNumber = (x) => {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
      }

    const dropDecimals = (number, decimals = 18) => {
        const str = number.toString()
        return str.substr(0, str.length - decimals)
    }

    const prettyDecimals = (number, decimals = 18) => {
        const str = number.toString()
        return `${str.substr(0, str.length - decimals)},${str.substr(decimals)}`
    }

    return {
        convertToNumber,
        convertToDisplayable,
        prettyNumber,
        dropDecimals,
        prettyDecimals
    }
}
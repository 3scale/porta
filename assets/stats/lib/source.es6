export class StatsSource {
  params () {
    throw new Error('It should implement params method in subclasses.')
  }

  data () {
    throw new Error('It should implement data method in subclasses.')
  }

  get url () {
    throw new Error('It should implement url getter in subclasses.')
  }
}

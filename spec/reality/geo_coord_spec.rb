module Reality
  module Geo
    describe Coord do
      let(:coord1) {Coord.new(50.004, 36.231)}
      let(:coord2) {Coord.new(50.45, 30.523)}

      describe :initialize do
        subject(:coord){Coord.new(100, 200)}
        it{should have_attributes(
          lat: Rational(100),
          latitude: Rational(100),
          lng: Rational(200),
          longitude: Rational(200)
        )}
      end

      describe :== do
        subject(:coord){Coord.new(100, 200)}
        let(:equal){Coord.new(100, 200)}
        let(:not_equal){Coord.new(110, 200)}

        it{should == equal}
        it{should_not == not_equal}
      end
      
      describe :from_dms do
        context 'with degs sign' do
          subject(:coord){Coord.from_dms([38, 53, 23], [-77, 00, 32])}
          let(:blueprint){Coord.new(38.8897, -77.0089)}
          its(:'lat.to_f'){should be_within(0.01).of(blueprint.lat.to_f)}
          its(:'lng.to_f'){should be_within(0.01).of(blueprint.lng.to_f)}
        end

        context 'with direction' do
          subject(:coord){Coord.from_dms([38, 53, 23, 'N'], [77, 00, 32, 'W'])}
          let(:blueprint){Coord.new(38.8897, -77.0089)}
          its(:'lat.to_f'){should be_within(0.01).of(blueprint.lat.to_f)}
          its(:'lng.to_f'){should be_within(0.01).of(blueprint.lng.to_f)}
        end

        context 'when incomplete' do
          subject(:coord){Coord.from_dms([38, 'N'], [77, 'W'])}
          let(:blueprint){Coord.new(38, -77)}
          its(:'lat.to_f'){should be_within(0.01).of(blueprint.lat.to_f)}
          its(:'lng.to_f'){should be_within(0.01).of(blueprint.lng.to_f)}
        end
      end

      describe :to_dms do
        subject(:coord){Coord.new(38.8897, -77.0089)}

        it 'converts with direction' do
          lat = coord.lat_dms
          d, m, s, dir = *lat
          expect(d).to eq 38
          expect(m).to eq 53
          expect(s).to within(0.1).of(23)
          expect(dir).to eq 'N'

          lng = coord.lng_dms
          d, m, s, dir = *lng
          expect(d).to eq 77
          expect(m).to eq 00
          expect(s).to within(0.1).of(32)
          expect(dir).to eq 'W'
        end

        it 'converts with sign' do
          lat = coord.lat_dms(false)
          d, m, s, dir = *lat
          expect(d).to eq 38
          expect(m).to eq 53
          expect(s).to within(0.1).of(23)
          expect(dir).to be_nil

          lng = coord.lng_dms(false)
          d, m, s, dir = *lng
          expect(d).to eq -77
          expect(m).to eq 00
          expect(s).to within(0.1).of(32)
          expect(dir).to be_nil
        end
      end

      describe :distance_to do
        subject { coord1.distance_to(coord2) }

        it{
          should be_within(Measure.new(0.1, 'km')).of(Measure.new(409.3, 'km'))
        }
      end

      describe :direction_to do
        subject { coord1.direction_to(coord2) }

        it{
          should be_within(Measure.new(0.5, '°')).of(Measure.new(279, '°'))
        }
      end

      describe :endpoint do
        subject { coord1.endpoint(279, 409) }

        it 'returns correct point' do
          expect(subject).to be_close_to(coord2, 10)
        end
      end

      describe :inspect do
        subject(:coord){Coord.from_dms([38, 53, 23], [-77, 00, 32])}
        its(:inspect){should == '#<Reality::Geo::Coord(38°53′23″N,77°0′32″W)>'}

        context 'corner case (needs ceiling)' do
          subject(:coord){Coord.from_dms([34,35,58,'S'], [58,22,54,'W'])}
          its(:inspect){should == '#<Reality::Geo::Coord(34°35′58″S,58°22′54″W)>'}
        end
      end

      describe :to_s do
        subject{coord1}
        its(:to_s){should == "#{subject.lat.to_f},#{subject.lng.to_f}"}
      end

      describe :to_h do
        subject{coord1}
        its(:to_h){should == {lat: subject.lat.to_f, lng: subject.lng.to_f}}
      end

      describe :latlng do
        subject{coord1}
        its(:latlng){should == subject.to_s}
      end

      describe :links do
        subject{coord1}

        it 'returns http links to set of maps' do
          expect(subject.links.keys).to match(%w[osm google wikimapia])
        end
      end
    end
  end
end
